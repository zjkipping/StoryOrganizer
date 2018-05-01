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
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Lobster", size: 20)! ]
        navigationController?.navigationBar.barTintColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        do {
            events = try managedContext.fetch(fetchRequest)
            print(events)
            tableView.reloadData()
        } catch {
            print("Could not fetch")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showActionAlert(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "New Event", style: .default , handler:{ (UIAlertAction)in
            self.performSegue(withIdentifier: "showNewEvent", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "New Recording", style: .default , handler:{ (UIAlertAction)in
            self.performSegue(withIdentifier: "showNewRecording", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showEventDetails") {
            let selectedIndexPath = tableView.indexPathForSelectedRow
            let destinationController = segue.destination as! EventDetailsViewController
            
            destinationController.event = self.events[selectedIndexPath?.row ?? 0]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath)
        let event = events[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = dateFormatter.string(for: event.date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteEvent(at: indexPath, event: events, tableView: tableView)
        }
    }
    
    @IBAction func searchChanged(_ sender: UITextField) {
        print(sender.text ?? "")
    }
    
    func deleteEvent(at indexPath: IndexPath, event: [Event], tableView: UITableView) {
        let event = events[indexPath.row]

        guard let managedContext = event.managedObjectContext else {
            return
        }
        
        // also need to delete the recording files...

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
}
