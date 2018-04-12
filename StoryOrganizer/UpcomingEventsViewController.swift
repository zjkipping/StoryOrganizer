//
//  UpcomingEventsViewController.swift
//  StoryOrganizer
//
//  Created by Zachary Kipping on 4/5/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//

import UIKit
import CoreData

class UpcomingEventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var events: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        do {
            events = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Could not fetch")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showNewRecording") {
            let destinationController = segue.destination as! NewRecordingViewController
            
            // eventually set this to the Event.name
            // destinationController.saveDirectory = event.name
        } else if (segue.identifier == "showNewEvent") {
            let destinationController = segue.destination as! NewEventViewController
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Event", for: indexPath) as! EventTableViewCell
        //let event = events[indexPath.row]
        
        cell.title.text = "Test"
        //cell.name.text = event.name
        //cell.date.text = event.date
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteEvent(at: indexPath, event: events, tableView: tableView)
        }
    }
    
    @IBAction func searchChanged(_ sender: UITextField) {
        // filter the events list here
        print(sender.text!)
    }
    
    @IBAction func clickedNew(_ sender: UIButton) {
        // segue to either new event or new recording
        // for now segue to new recording, need to research hold button for multiple options
        
        performSegue(withIdentifier: "showNewEvent", sender: self)
        
        // performSegue(withIdentifie: "showNewRecording", sender: self)
    }
    
    func deleteEvent(at indexPath: IndexPath, event: [Event], tableView: UITableView) {
        let event = events[indexPath.row]

        guard let managedContext = event.managedObjectContext else {
            return
        }

        managedContext.delete(event)

        do {
            try managedContext.save()

            events.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            print("Could not delete")

            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

//extension UpcomingEventsViewController: UITableViewDataSource, UITableViewDelegate {
//
//}
