//
//  PlaybackViewController.swift
//  StoryOrganizer
//
//  Created by Zachary Kipping on 4/5/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//

import UIKit

import AVFoundation

class PlaybackViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var flagTableView: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scrubSlider: UISlider!
    @IBOutlet weak var flagButton: UIButton!
    
    var playbackTimer: Timer!
    var avPlayer: AVPlayer!
    var avItem: AVPlayerItem!
    var recording: Recording?
    var finished: Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //don't touch
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Lobster", size: 20)! ]
        navigationController?.navigationBar.barTintColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        //>:(
        
        // either the recording has the flag list or we need to load them in somehow
        
        self.flagTableView.dataSource = self
        self.flagTableView.delegate = self
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
            try AVAudioSession.sharedInstance().setActive(true)
            if let recording = self.recording, let media = recording.media {
                let url = getDocumentsDirectory().appendingPathComponent(media)
                
                self.avItem = AVPlayerItem(url: url)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avItem)
                
                self.avPlayer = AVPlayer(playerItem: self.avItem)
                
                self.playbackTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.playbackLoop), userInfo: nil, repeats: true)

                self.playButton.isEnabled = true
                self.restartButton.isEnabled = true
                self.scrubSlider.isEnabled = true
                self.flagButton.isEnabled = true
                
                self.scrubSlider.maximumValue = Float(CMTimeGetSeconds(self.avItem.asset.duration))
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        // Do any additional setup after loading the view.
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.playButton.setImage(UIImage(named: "play.png"), for: .normal)
        self.finished = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recording?.flags?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flag", for: indexPath)
        
        guard let recording = self.recording, let flags = recording.flags else {
            return cell
        }
        
        let flag = flags[indexPath.row] as! Flag
        
        cell.textLabel?.text = "\(flag.name ?? "") \(String(format: "%.2f", flag.time)) seconds"

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let recording = self.recording, let flags = recording.flags else {
            return
        }
        
        let flag = flags[indexPath.row] as! Flag
        self.avPlayer.seek(to: CMTime.init(seconds: flag.time, preferredTimescale: 1000))
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let recording = recording {
                deleteFlag(at: indexPath, recording: recording, tableView: flagTableView)
            }
        }
    }
    
    func deleteFlag(at indexPath: IndexPath, recording: Recording, tableView: UITableView) {
        guard let flags = recording.flags else {
            return
        }
        
        let flag = flags[indexPath.row] as! Flag
        
        guard let managedContext = flag.managedObjectContext else {
            return
        }
        
        managedContext.delete(flag)
        
        do {
            try managedContext.save()
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            print("Could not delete")
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    @IBAction func flagButtonClicked(_ sender: UIButton) {
        if let recording = recording, let flags = recording.flags {
            do {
                if let flag = Flag(name: "Flag\(flags.count + 1)", time: Double(CMTimeGetSeconds(self.avPlayer.currentTime()))) {
                    var index = 0;
                    for i in 0 ... flags.count - 1 {
                        if ((flags[i] as! Flag).time <= flag.time) {
                            index = i + 1
                        }
                    }
                    recording.insertIntoFlags(flag, at: index)
                    try flag.managedObjectContext?.save()
                    flagTableView.reloadData()
                }
            } catch {
                print("Failed to make new flag")
            }
        }
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        self.avPlayer.seek(to: CMTime.init(seconds: Double(self.scrubSlider.value), preferredTimescale: 1000))
    }
    
    @objc func playbackLoop() {
        // handle updates from the record session: time, channel values, etc...
        if (self.avPlayer != nil) {
            self.scrubSlider.value = Float(CMTimeGetSeconds(self.avPlayer.currentTime()))
            let rawSeconds = Double(CMTimeGetSeconds(self.avPlayer.currentTime()))
            
            let minutes: Int = Int(rawSeconds / 60)
            
            let seconds: Int = Int(rawSeconds.truncatingRemainder(dividingBy: 60))
            
            let milliseconds: Int = Int((rawSeconds.truncatingRemainder(dividingBy: 60) * 100).truncatingRemainder(dividingBy: 100))
            
            
            self.timeLabel.text = "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds)):\(String(format: "%02d", milliseconds))"
        }
    }
    
    @IBAction func playPressed(_ sender: UIButton) {
        if self.avPlayer != nil {
            if (self.finished == true) {
                self.finished = false
                self.avPlayer.seek(to: kCMTimeZero)
                self.avPlayer.play()
                self.playButton.setImage(UIImage(named: "pause.png"), for: .normal)
                return
            }
            if (self.avPlayer.timeControlStatus == .playing) {
                self.avPlayer.pause()
                self.playButton.setImage(UIImage(named: "play.png"), for: .normal)
            } else if (self.avPlayer.timeControlStatus == .paused) {
                self.avPlayer.play()
                self.playButton.setImage(UIImage(named: "pause.png"), for: .normal)
            }
        }
    }
    
    @IBAction func restartPressed(_ sender: UIButton) {
        if self.avPlayer != nil {
            self.avPlayer.seek(to: kCMTimeZero)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        // gets the path for the general documents directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
