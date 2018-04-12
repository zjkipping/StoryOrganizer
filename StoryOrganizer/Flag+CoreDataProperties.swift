//
//  Flag+CoreDataProperties.swift
//  StoryOrganizer
//
//  Created by Adam Thoma-Perry on 4/12/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//
//

import Foundation
import CoreData


extension Flag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Flag> {
        return NSFetchRequest<Flag>(entityName: "Flag")
    }

    @NSManaged public var name: String?
    @NSManaged public var time: Double
    @NSManaged public var recording: Recording?

}
