//
//  Flag+CoreDataClass.swift
//  StoryOrganizer
//
//  Created by Adam Thoma-Perry on 4/12/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Flag)
public class Flag: NSManagedObject {

    convenience init?(name: String?, time: Double) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        guard let context = appDelegate?.persistentContainer.viewContext else {
            return nil
        }
        
        self.init(entity: Flag.entity(), insertInto: context)
        
        self.name = name
        self.time = time
    }
}
