//
//  NewEventViewController.swift
//  StoryOrganizer
//
//  Created by Zachary Kipping on 4/5/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//

import UIKit
import CoreData
import os.log

class NewEventViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var topicTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var existingEvent: Event?
    
    var callbackHandler: ((Event) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initialize UI datepicker on view controller
        createDatePicker()
        
        self.title = existingEvent == nil ? "New Event" : "Edit Event"
        
        nameTextField.text = existingEvent?.name
        topicTextField.text = existingEvent?.topic
        phoneTextField.text = existingEvent?.phone
        emailTextField.text = existingEvent?.email
        addressTextField.text = existingEvent?.address
        if let date = existingEvent?.date {
            datePicker.date = date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let dateString = formatter.string(from: datePicker.date)
            dateTextField.text = "\(dateString)"
        }
    }
    
    let datePicker = UIDatePicker()
    
    func createDatePicker(){
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        //bar button item
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        dateTextField.inputAccessoryView = toolbar
        //assigning date picker to text field
        dateTextField.inputView = datePicker
        datePicker.datePickerMode = .date
    }
    
    @objc func donePressed(){
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: datePicker.date)
        dateTextField.text = "\(dateString)"
        self.view.endEditing(true)
    }
    
    var testEventTopic : String?
    var testEventName: String?
    var testEventphone: String?
    var testEventemail: String?
    var testEventaddress: String?
    var testEventDate: Date?
    
    @IBAction func saveNewEvent(_ sender: Any) {
        var checkEmptyField : Bool = true
        //if there is a value, unwrap it and place it into event struct, else set checkEmptyfield = false
        //if checkempty field is false, a popup will occur
        if let topic = topicTextField.text, !topic.isEmpty {
            testEventTopic = topic
            topicTextField.layer.borderWidth = 0
        } else {
            //change color of textfield for visual cue
            topicTextField.layer.borderWidth = 1.0
            topicTextField.layer.borderColor = UIColor.red.cgColor
            checkEmptyField = false
        }
        
        if let name = nameTextField.text, !name.isEmpty {
            testEventName = name
            nameTextField.layer.borderWidth = 0
        } else {
            //change color of textfield for visual cue
            nameTextField.layer.borderWidth = 1.0
            nameTextField.layer.borderColor = UIColor.red.cgColor
            checkEmptyField = false
        }
        
        //if there is a value, unwrap it and place it into event struct, else set checkEmptyfield = false
        //if checkempty field is false, a popup will occur
        if let topic = topicTextField.text, !topic.isEmpty {
            testEventTopic = topic
            topicTextField.layer.borderWidth = 0
        } else {
            //change color of textfield for visual cue
            topicTextField.layer.borderWidth = 1.0
            topicTextField.layer.borderColor = UIColor.red.cgColor
            checkEmptyField = false
        }
        if let name = nameTextField.text, !name.isEmpty {
            testEventName = name
            nameTextField.layer.borderWidth = 0
        } else {
            //change color of textfield for visual cue
            nameTextField.layer.borderWidth = 1.0
            nameTextField.layer.borderColor = UIColor.red.cgColor
            checkEmptyField = false
        }
        if let phone = phoneTextField.text, !phone.isEmpty {
            testEventphone = phone
            phoneTextField.layer.borderWidth = 0
        } else {
            //change color of textfield for visual cue
            phoneTextField.layer.borderWidth = 1.0
            phoneTextField.layer.borderColor = UIColor.red.cgColor
            checkEmptyField = false
        }
        if let email = emailTextField.text, !email.isEmpty {
            testEventemail = email
            emailTextField.layer.borderWidth = 0
        } else {
            //change color of textfield for visual cue
            emailTextField.layer.borderWidth = 1.0
            emailTextField.layer.borderColor = UIColor.red.cgColor
            checkEmptyField = false
        }
        if let address = addressTextField.text, !address.isEmpty {
            testEventaddress = address
            addressTextField.layer.borderWidth = 0
        } else {
            //change color of textfield for visual cue
            addressTextField.layer.borderWidth = 1.0
            addressTextField.layer.borderColor = UIColor.red.cgColor
            checkEmptyField = false
        }
        if let date = dateTextField.text, !date.isEmpty {
            testEventDate = datePicker.date
            dateTextField.layer.borderWidth = 0

        } else {
            //change color of textfield for visual cue
            dateTextField.layer.borderWidth = 1.0
            dateTextField.layer.borderColor = UIColor.red.cgColor
        }
        //if statement to check if a textfield is left empty
        if(checkEmptyField == false){
            let alert = UIAlertController(title: "Missing Information", message: "Please fill in missing field or enter correct date format.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"Okay", style: .default, handler:nil))
            self.present(alert, animated:true)
        } else {
            //returns to root view controller
            self.navigationController!.popToRootViewController(animated: true)
            
            if let existingEvent = existingEvent {
                    existingEvent.topic = topicTextField.text
                    existingEvent.name = nameTextField.text
                    existingEvent.phone = phoneTextField.text
                    existingEvent.email = emailTextField.text
                    existingEvent.address = addressTextField.text
                    existingEvent.date = datePicker.date
                do {
                    try existingEvent.managedObjectContext?.save()
                    if let callback = self.callbackHandler {
                        self.dismiss(animated: true) {
                            callback(existingEvent)
                        }
                    }
                }
                catch{
                    print("Could not create entity.")
                }
            } else if let event = Event(name: testEventName, topic: testEventTopic, phone: testEventphone, email: testEventemail, address: testEventaddress, date: testEventDate){
                do {
                    try event.managedObjectContext?.save()
                    if let callback = self.callbackHandler {
                        self.dismiss(animated: true) {
                            callback(event)
                        }
                    }
                }
                catch{
                    print("Could not create entity.")
                }
            }
        }
    }
}

