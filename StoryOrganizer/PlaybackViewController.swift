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
    
    var player: AVAudioPlayer!
    var recording: Recording?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // either the recording has the flag list or we need to load them in somehow
        
        self.flagTableView.dataSource = self
        self.flagTableView.delegate = self

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let url = getDocumentsDirectory().appendingPathComponent(recording!.media!)
            
            self.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            
            self.player.isMeteringEnabled = true
            // do same audio visualization as the new recording page?
            
            self.playButton.isEnabled = true
            self.restartButton.isEnabled = true
        } catch let error {
            print(error.localizedDescription)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flag", for: indexPath)
        
        //        cell.textLabel!.text = "Flag Time: \(String(format: "%.2f", self.flags[indexPath.row])) seconds"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // self.player.currentTime = flags[indexPath.row].time
    }
    
    @IBAction func playPressed(_ sender: UIButton) {
        if self.player != nil {
            if (self.player.isPlaying) {
                self.player.pause()
                self.playButton.setTitle("Resume", for: .normal)
            } else {
                self.player.play()
                self.playButton.setTitle("Pause", for: .normal)
            }
        }
    }

    @IBAction func restartPressed(_ sender: UIButton) {
        if self.player != nil {
            self.player.currentTime = 0
        }
    }
    
    func getDocumentsDirectory() -> URL {
        // gets the path for the general documents directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(paths[0])
        return paths[0]
    }
}
