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

class NewRecordingViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
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
    var saveDirectory: String = "temp"
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var flagQuoteButton: UIButton!
    @IBOutlet weak var flagTable: UITableView!
    
    var eventRelationship: Event?
    var recording: Recording?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //don't touch
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Lobster", size: 20)! ]
        navigationController?.navigationBar.barTintColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        //>:(
        
        self.flagTable.dataSource = self
        self.flagTable.delegate = self
        
        self.attemptSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveRecording() {
        if let recording = Recording(name: fileName, media: mediaRef, date: Date.init()) {
            // saves the recording/flags and relates them to the proper event
            eventRelationship?.addToRecordings(recording)
            do {
                try recording.managedObjectContext?.save()
            } catch {
                print("Recording could not be created")
            }
            if (!self.flags.isEmpty) {
                do {
                    for flag in self.flags {
                        recording.addToFlags(flag)
                        try flag.managedObjectContext?.save()
                    }
                } catch {
                    print("Flag could not be created")
                }
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
        
        let flag = self.flags[indexPath.row]
        
        cell.textLabel?.text = "\(flag.name ?? "")  |  \(String(format: "%.2f", flag.time)) seconds"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteFlag(at: indexPath, tableView: flagTable)
        }
    }
    
    func deleteFlag(at indexPath: IndexPath, tableView: UITableView) {
        flags.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
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
        self.recorder == nil ? self.startRecording() : self.finishRecording(true)
    }
    
    @IBAction func pausePressed(_ sender: UIButton) {
        // swap between paused and recording state
        if self.recorder != nil {
            if (self.recorder.isRecording) {
                self.recorder.pause()
                self.pauseButton.setImage(UIImage(named: "play.png"), for: .normal)
            } else {
                self.recorder.record()
                self.pauseButton.setImage(UIImage(named: "pause.png"), for: .normal)
            }
        }
    }
    
    func recordingSetup() {
        // getting the directory to save the new audio file to
        if let event = self.eventRelationship{
            self.saveDirectory = event.getID()
        }
        // create the folder for the event if it doesn't exist
        if (URL.createFolder(folderName: self.saveDirectory) == nil) {
            self.finishRecording(false)
            return;
        }
        // check to see if fileName with id from above exists, slight chance if files are deleted
        self.fileName = "\(randomString(length: 32)).m4a"
        // file should have a unique name now so it can be saved
        self.mediaRef = self.saveDirectory + "/" + self.fileName
    }
    
    func startRecording() {
        do {
            let audioFileName = getDocumentsDirectory().appendingPathComponent(self.mediaRef)
            
            // prepare the recorder with the info derived from above
            self.recorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            self.recorder.delegate = self
            self.recorder.isMeteringEnabled = true
            self.recorder.prepareToRecord()

            // start the recorder, timer, and swap buttons to currently recording values
            self.recorder.record()
            self.recordingTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.recordLoop), userInfo: nil, repeats: true)
            self.recordButton.setImage(UIImage(named: "stop.png"), for: .normal)
            self.pauseButton.isEnabled = true
            self.flagQuoteButton.isEnabled = true
        } catch {
            self.finishRecording(false)
        }
    }
    
    func finishRecording(_ success: Bool) {
        // clear recorder
        self.recorder.stop()
        self.recorder = nil
        
        // reset the buttons to orig states
        self.recordButton.setImage(UIImage(named: "record.png"), for: .normal)
        self.pauseButton.setImage(UIImage(named: "pause.png"), for: .normal)
        self.pauseButton.isEnabled = false
        self.flagQuoteButton.isEnabled = false
        self.recordButton.isEnabled = false
        
        // stop the timer/display updater
        self.recordingTimer.invalidate()
        
        if success {
            // create Recording instance with file ref, name, and current date
            
            if self.eventRelationship != nil {
                self.saveRecording()
                // need to save this to core data based on the event?
            } else {
                // show new event modal
                
                // Need to setup NewEventViewController as a proper modal?
                if let newEventVC = self.storyboard?.instantiateViewController(withIdentifier: "NewEvent") as? NewEventViewController {
                    newEventVC.callbackHandler = {
                        (event) in
                        self.eventRelationship = event
                        self.moveTempFile()
                        self.saveRecording()
                    }
                    self.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    self.modalPresentationStyle = .currentContext
                    let navBarOnModal: UINavigationController = UINavigationController(rootViewController: newEventVC)
                    self.present(navBarOnModal, animated: true, completion: nil)
                }
            }
        } else {
            // recording unsuccessfully finished, delete file created?
            do {
                try fileManager.removeItem(at: getDocumentsDirectory().appendingPathComponent(mediaRef))
            } catch {
                // file doesn't exist
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func moveTempFile() {
        if let event = self.eventRelationship {
            var newUrl = URL.createFolder(folderName: event.getID())!
            newUrl.appendPathComponent(self.fileName)
            let oldUrl = getDocumentsDirectory().appendingPathComponent(self.mediaRef)
            do {
                try self.fileManager.moveItem(at: oldUrl, to: newUrl)
                self.mediaRef = event.getID() + "/" + self.fileName
            } catch {
                print("Failed to move audio file")
            }
        }
    }
    
    @objc func recordLoop() {
        // handle updates from the record session: time, channel values, etc...
        if (recorder.isRecording) {
            let minutes: Int = Int(self.recorder.currentTime / 60)
            
            let seconds: Int = Int(self.recorder.currentTime.truncatingRemainder(dividingBy: 60))
            
            let milliseconds: Int = Int((self.recorder.currentTime.truncatingRemainder(dividingBy: 60) * 100).truncatingRemainder(dividingBy: 100))
            

            self.timeLabel.text = "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds)):\(String(format: "%02d", milliseconds))"
            
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
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    @IBAction func flagQuote(_ sender: UIButton) {
        // add current recording time as a flag to the list of flags, update the list view
        if (self.recorder != nil && self.recorder.isRecording) {
            let flag = Flag(name: "Flag\(self.flags.count + 1)", time: self.recorder.currentTime)
            self.flags.append(flag!)
            self.flagTable.beginUpdates()
            self.flagTable.insertRows(at: [IndexPath(row: self.flags.count-1, section: 0)], with: .automatic)
            self.flagTable.endUpdates()
        }
    }
}
