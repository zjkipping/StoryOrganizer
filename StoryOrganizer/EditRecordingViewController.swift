//
//  EditRecordingViewController.swift
//  StoryOrganizer
//
//  Created by Weston Verhulst on 5/7/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//

import UIKit

class EditRecordingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var flagTableView: UITableView!
    @IBOutlet weak var recordingNameTextField: UITextField!
    
    var flagsText: [UITextField] = []
    var recording : Recording?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.flagTableView.dataSource = self
        self.flagTableView.delegate = self
        
        recordingNameTextField.text = recording?.name ?? ""
        flagTableView.reloadData()
        
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
        return self.recording?.flags?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editFlag", for: indexPath) as! EditRecordingTableViewCell
        
        guard let recording = self.recording, let flags = recording.flags else {
            return cell
        }

        let flag = flags[indexPath.row] as! Flag
        
        
        cell.textField.delegate = self // theField is your IBOutlet UITextfield in your custom cell
        
        cell.textField.text = flag.name ?? ""
        
        cell.textField.placeholder = flag.name ?? ""
        
        flagsText.append(cell.textField)
        
        return cell
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        for i in 0 ... flagsText.count - 1 {
            if (flagsText[i].placeholder == textField.placeholder) {
                flagsText[i].text = textField.text
            }
        }
    }

    @IBAction func saveClicked(_ sender: Any) {
        if let recording = recording, let flags = recording.flags {
            recording.name = recordingNameTextField.text
            do {
                for i in 0 ... flags.count - 1 {
                    let flag = flags[i] as! Flag
                    
                    flag.name = flagsText[i].text
                    try flag.managedObjectContext?.save()
                }
                try recording.managedObjectContext?.save()
                navigationController?.popViewController(animated: true)
            } catch {
                print("something messed up")
            }
        }
    }
}
