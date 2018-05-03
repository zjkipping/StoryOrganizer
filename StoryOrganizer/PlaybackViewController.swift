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
        self.avPlayer.seek(to: CMTime.init(seconds: flag.time, preferredTimescale: 1))
    }
    
    @objc func playbackLoop() {
        // handle updates from the record session: time, channel values, etc...
        if (self.avPlayer != nil) {
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
                self.playButton.setImage(UIImage(named: "resume.png"), for: .normal)
            } else if (self.avPlayer.timeControlStatus == .paused) {
                self.avPlayer.play()
                self.playButton.setImage(UIImage(named: "pause.png"), for: .normal)
            }
        }
    }
    
    @IBAction func restartPressed(_ sender: UIButton) {
        if self.avPlayer != nil {
            self.avPlayer.seek(to: kCMTimeZero)
            if (self.finished) {
                self.finished = false
                self.avPlayer.play()
                self.playButton.setImage(UIImage(named: "pause.png"), for: .normal)
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        // gets the path for the general documents directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
