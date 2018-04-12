//
//  NewEventViewController.swift
//  StoryOrganizer
//
//  Created by Zachary Kipping on 4/5/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//

import UIKit

class NewEventViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var topicTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        topicTextField.delegate = self
        dateTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        addressTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        topicTextField.resignFirstResponder()
    }
    
    @IBAction func saveEvent(_ sender: Any) {
        let event = Event(name: nameTextField.text ?? "",
                          topic: topicTextField.text ?? "",
                          phone: phoneTextField.text ?? "",
                          email: emailTextField.text ?? "",
                          address: addressTextField.text ?? "",
                          date: datePicker.date)
        
        do {
            try event?.managedObjectContext?.save()
            self.navigationController?.popViewController(animated: true)
        } catch {
            print("Could not save event")
        }
    }
}

extension NewEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
