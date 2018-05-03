//
//  Recording+CoreDataClass.swift
//  StoryOrganizer
//
//  Created by Adam Thoma-Perry on 4/12/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Recording)
public class Recording: NSManagedObject {
    
    var date: Date? {
        get {
            return rawDate as Date?
        }
        set {
            rawDate = newValue as NSDate?
        }
    }
    
    convenience init?(name: String?, media: String?, date: Date?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        guard let context = appDelegate?.persistentContainer.viewContext else {
            return nil
        }
        
        self.init(entity: Recording.entity(), insertInto: context)
        
        self.name = name
        self.media = media
        self.date = date
    }
}

extension Recording {
    public func getID() -> String {
        return String(self.objectID.uriRepresentation().absoluteString.last ?? "0")
    }
}
