//
//  NewEventViewController.swift
//  StoryOrganizer
//
//  Created by Zachary Kipping on 4/5/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//

import UIKit

//struct Event {
//    var topic: String?
//    var name: String?
//    var phone: String?
//    var email: String?
//    var address: String?
//    var date: String?
//}

class NewEventViewController: UIViewController, UITextFieldDelegate {
    
    //list of textfield outlets
    @IBOutlet weak var topicTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    //save button on navbar
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
//    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        createDatePicker()
        
    }
    
//    func createDatePicker(){
//
//        //toolbar
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//
//        //bar button item
//        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
//        toolbar.setItems([doneButton], animated: false)
//
//        dateTextField.inputAccessoryView = toolbar
//
//        //assigning date picker to text field
//        dateTextField.inputView = datePicker
//
//    }
//
//    func donePressed(){
//        dateTextField.text = "\(datePicker.date)"
//        self.view.endEditing(true)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    

  

    
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
                //convert string to date
                let isoDate = date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                let date = dateFormatter.date(from:isoDate)
                let calendar = Calendar.current
//                let components = calendar.dateComponents([.year, .month, .day], from: date!)
//                let finalDate = calendar.date(from:components)
//
                if let testDate = date{
                let components = calendar.dateComponents([.year, .month, .day], from: date!)
                    _ = calendar.date(from:components)
                testEventDate = testDate
                dateTextField.layer.borderWidth = 0
                }else{
                    checkEmptyField = false
                    dateTextField.layer.borderWidth = 1.0
                    dateTextField.layer.borderColor = UIColor.red.cgColor
                }
                
            } else {
                //change color of textfield for visual cue
                dateTextField.layer.borderWidth = 1.0
                dateTextField.layer.borderColor = UIColor.red.cgColor
                checkEmptyField = false
            }
            
            //if statement to check if a textfield is left empty
            if(checkEmptyField == false){
                let alert = UIAlertController(title: "Missing Information", message: "Please fill in missing field or enter correct date format.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:"Okay", style: .default, handler:nil))
                self.present(alert, animated:true)
            } else {
                //returns to root view controller
                self.navigationController!.popToRootViewController(animated: true)
            
                if let event = Event(name: testEventName, topic: testEventTopic, phone: testEventphone, email: testEventemail, address: testEventaddress, date: testEventDate){
            do {
                try event.managedObjectContext?.save()
            }
            catch {
                print("Could not create entity.")
                    }}
            }
        
    }
}
