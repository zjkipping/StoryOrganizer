//
//  NewRecordingViewController.swift
//  StoryOrganizer
//
//  Created by Zachary Kipping on 4/5/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class NewRecordingViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate {
    let fileManager: FileManager = FileManager.default
    var session: AVAudioSession!
    var recorder: AVAudioRecorder!
    var recordingTimer: Timer!
    var flags: [Flag] = []
    var settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    var fileName: String = ""
    var mediaRef: String = ""
    var saveDirectory: String?
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var flagQuoteButton: UIButton!
    @IBOutlet weak var flagTable: UITableView!
    
    var eventRelationship: Event?
    var recordingRelationship: Recording?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.flagTable.dataSource = self
        self.flagTable.delegate = self
        
        self.attemptSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveRecording() {

        if let recording = Recording(name: fileName, media: mediaRef, date: Date.init()) {
            
            eventRelationship?.addToRecordings(recording)
            
            do {
                for flag in self.flags {
                    try flag.managedObjectContext?.save()
                }
            } catch {
                print("Flag could not be created")
            }
            
            recordingRelationship?.addToFlags(flags)
            
            do {
                try recording.managedObjectContext?.save()
                self.navigationController?.popViewController(animated: true)
            } catch {
                print("Recording could not be created")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.flags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flag", for: indexPath)
        
        cell.textLabel?.text = "\(self.flags) \(String(format: "%.2f", self.flags[indexPath.row])) seconds"
        
        return cell
    }
    
    func attemptSession() {
        // attempts to create a Audio Session +  get permission from user
        session = AVAudioSession.sharedInstance()
        do {
            try self.session.setCategory(AVAudioSessionCategoryRecord)
            try self.session.setActive(true)
            self.session.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.permissionSuccess()
                    } else {
                        self.permissionFailed()
                    }
                }
            }
        } catch {
            self.sessionFailed()
        }
    }
    
    func sessionFailed() {
        // something messed up with the recording session init process
    }
    
    func permissionSuccess() {
        // allow to use start recording button, setup other things here as well
        self.recordingSetup()
        self.recordButton.isEnabled = true
    }
    
    func permissionFailed() {
        // show error about user denying permission to record
    }
    
    @IBAction func recordPressed(_ sender: UIButton) {
        // swap between start recording and end recording states
        (self.recorder.currentTime == 0.0 || self.recorder == nil) ? self.startRecording() : self.finishRecording(true)
    }
    
    @IBAction func pausePressed(_ sender: UIButton) {
        // swap between paused and recording state
        if self.recorder != nil {
            if (self.recorder.isRecording) {
                self.recorder.pause()
                self.pauseButton.setTitle("Resume", for: .normal)
            } else {
                self.recorder.record()
                self.pauseButton.setTitle("Pause", for: .normal)
            }
        }
    }
    
    func recordingSetup() {
        do {
            // getting the directory to save the new audio file to
            var directory = "temp"
            if let saveDirectory = self.saveDirectory {
                directory = saveDirectory
            }
            
            // check to see the contents of said directory
            let contents = try self.fileManager.contentsOfDirectory(at: self.getDocumentsDirectory().appendingPathComponent(directory), includingPropertiesForKeys: nil)
            // get the counts of audio files in the folder
            var recordingCount = 1
            for file in contents {
                if (file.pathExtension.contains("m4a")) {
                    recordingCount += 1
                }
            }
            
            // check to see if fileName with id from above exists, slight chance if files are deleted
            self.fileName = "recording\(recordingCount).m4a"
            while(self.fileManager.fileExists(atPath: directory + "/" + self.fileName)) {
                recordingCount += 1
                self.fileName = "recording\(recordingCount).m4a"
            }
            // file should have a unique name now so it can be saved
            self.mediaRef = directory + "/" + self.fileName
            
            // either create a folder with the directory name + URL to it, or get the URL of the existing directory
            if let url = URL.createFolder(folderName: directory) {
                let audioFileName = url.appendingPathComponent(self.fileName)
                print(audioFileName.absoluteString)
                
                // prepare the recorder with the info derived from above
                self.recorder = try AVAudioRecorder(url: audioFileName, settings: settings)
                self.recorder.delegate = self
                self.recorder.isMeteringEnabled = true
                self.recorder.prepareToRecord()
            } else {
                self.finishRecording(false)
            }
        } catch {
            self.finishRecording(false)
        }
    }
    
    func startRecording() {
        // start the recorder, timer, and swap buttons to currently recording values
        self.recorder.record()
        self.recordingTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.recordLoop), userInfo: nil, repeats: true)
        self.recordButton.setTitle("Stop", for: .normal)
        self.pauseButton.isEnabled = true
        self.flagQuoteButton.isEnabled = true
    }
    
    func finishRecording(_ success: Bool) {
        // clear recorder
        self.recorder.stop()
        self.recorder = nil
        
        // reset the buttons to orig states
        self.recordButton.setTitle("Record", for: .normal)
        self.pauseButton.setTitle("Pause", for: .normal)
        self.pauseButton.isEnabled = false
        self.flagQuoteButton.isEnabled = false
        self.recordButton.isEnabled = false
        
        // stop the timer/display updater
        self.recordingTimer.invalidate()
        
        if success {
            // create Recording instance with file ref, name, and current date
            
            if self.saveDirectory != nil {
                saveRecording()
                // need to save this to core data based on the event?
            } else {
                // show new event modal
                
                // Need to setup NewEventViewController as a proper modal?
                /*self.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                 self.modalPresentationStyle = .currentContext
                 self.present(NewEventViewController(), animated: true, completion: newEventCompleted)*/
                navigationController?.popViewController(animated: true)
            }
        } else {
            // recording unsuccessfully finished, delete file created?
            do {
                try fileManager.removeItem(at: getDocumentsDirectory().appendingPathComponent(mediaRef))
            } catch {
                // file doesn't exist
            }
            navigationController?.popViewController(animated: true)
        }
    }
    
    func newEventCompleted() {
        // somehow save recording to the new event (core data) and move file from temp folder to event folder
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func recordLoop() {
        // handle updates from the record session: time, channel values, etc...
        if (recorder.isRecording) {
            self.timeLabel.text = "Record Time: \(String(format: "%.0f", self.recorder.currentTime)) seconds"
            
            // some functionality for updating the volume metering
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        // function that runs when something weird happened to the app while recording (left app, closed app, navigated, etc...)
        if !flag {
            self.finishRecording(false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        // gets the path for the general documents directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func flagQuote(_ sender: UIButton) {
        // add current recording time as a flag to the list of flags, update the list view
        if (self.recorder != nil && self.recorder.isRecording) {
            let flag = Flag(name: "Flag \(self.flags.count)", time: self.recorder.currentTime)
            self.flags.append(flag!)
            self.flagTable.beginUpdates()
            self.flagTable.insertRows(at: [IndexPath(row: self.flags.count-1, section: 0)], with: .automatic)
            self.flagTable.endUpdates()
        }
    }

}
