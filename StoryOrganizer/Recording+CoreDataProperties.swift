//
//  Recording+CoreDataProperties.swift
//  StoryOrganizer
//
//  Created by Adam Thoma-Perry on 4/17/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//
//

import Foundation
import CoreData


extension Recording {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recording> {
        return NSFetchRequest<Recording>(entityName: "Recording")
    }

    @NSManaged public var media: String?
    @NSManaged public var name: String?
    @NSManaged public var rawDate: NSDate?
    @NSManaged public var event: Event?
    @NSManaged public var flags: NSOrderedSet?

}

// MARK: Generated accessors for flags
extension Recording {

    @objc(insertObject:inFlagsAtIndex:)
    @NSManaged public func insertIntoFlags(_ value: Flag, at idx: Int)

    @objc(removeObjectFromFlagsAtIndex:)
    @NSManaged public func removeFromFlags(at idx: Int)

    @objc(insertFlags:atIndexes:)
    @NSManaged public func insertIntoFlags(_ values: [Flag], at indexes: NSIndexSet)

    @objc(removeFlagsAtIndexes:)
    @NSManaged public func removeFromFlags(at indexes: NSIndexSet)

    @objc(replaceObjectInFlagsAtIndex:withObject:)
    @NSManaged public func replaceFlags(at idx: Int, with value: Flag)

    @objc(replaceFlagsAtIndexes:withFlags:)
    @NSManaged public func replaceFlags(at indexes: NSIndexSet, with values: [Flag])

    @objc(addFlagsObject:)
    @NSManaged public func addToFlags(_ value: [Flag])

    @objc(removeFlagsObject:)
    @NSManaged public func removeFromFlags(_ value: Flag)

    @objc(addFlags:)
    @NSManaged public func addToFlags(_ values: NSOrderedSet)

    @objc(removeFlags:)
    @NSManaged public func removeFromFlags(_ values: NSOrderedSet)

}
