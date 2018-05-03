//
//  EventDetailsViewController.swift
//  StoryOrganizer
//
//  Created by Zachary Kipping on 4/5/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var event: Event?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let event = self.event {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            self.nameLabel.text = event.name ?? ""
            self.topicLabel.text = event.topic ?? ""
            if let date = event.date {
                self.dateLabel.text = dateFormatter.string(from: date)
            }
            self.phoneLabel.text = event.phone ?? ""
            self.emailLabel.text = event.email ?? ""
            self.addressLabel.text = event.address ?? ""
            
            tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.event?.recordings?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recording", for: indexPath)
        if let event = self.event, let recordings = event.recordings {
            let recording: Recording = recordings[indexPath.row] as! Recording

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none

            cell.textLabel?.text = recording.name ?? ""
            if let date = recording.date {
                cell.detailTextLabel?.text = dateFormatter.string(for: date)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let event = self.event else {
                return
            }
            deleteRecording(at: indexPath, event: event, tableView: tableView)
        }
    }
    
    func deleteRecording(at indexPath: IndexPath, event: Event, tableView: UITableView) {
        guard let recordings = event.recordings else {
            return
        }
        
        let recording = recordings[indexPath.row] as! Recording
        
        guard let managedContext = recording.managedObjectContext else {
            return
        }
        
        managedContext.delete(recording)
        
        // also need to delete the m4a file as well at some point...
        
        do {
            try managedContext.save()
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            print("Could not delete")
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newRecording(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showNewRecording", sender: self)
    }

    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showNewRecording") {
            let destinationController = segue.destination as! NewRecordingViewController
            
            destinationController.eventRelationship = self.event
        } else if (segue.identifier == "showPlayback") {
            let destinationController = segue.destination as! PlaybackViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            
            destinationController.recording = self.event?.recordings?[selectedIndexPath?.row ?? 0] as? Recording
        } else if (segue.identifier == "showEventEdit"){
            let destinationController = segue.destination as! NewEventViewController
            guard let passingEvent = event else {
                return
            }
            destinationController.existingEvent = passingEvent
            
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
