//
//  Event+CoreDataClass.swift
//  StoryOrganizer
//
//  Created by Adam Thoma-Perry on 4/12/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Event)
public class Event: NSManagedObject {

    var date: Date? {
        get {
            return rawDate as Date?
        }
        set {
            rawDate = newValue as NSDate?
        }
    }
    
    convenience init?(name: String?, topic: String?, phone: String?, email: String?, address: String?, date: Date?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        guard let context = appDelegate?.persistentContainer.viewContext else {
            return nil
        }
        
        self.init(entity: Event.entity(), insertInto: context)
        
        self.name = name
        self.topic = topic
        self.phone = phone
        self.email = email
        self.address = address
        self.date = date
    }
}

extension Event {
    public func getID() -> String {
        return String(self.objectID.uriRepresentation().absoluteString.last ?? "0")
    }
}
