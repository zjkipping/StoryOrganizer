//
//  Event+CoreDataProperties.swift
//  StoryOrganizer
//
//  Created by Adam Thoma-Perry on 4/12/18.
//  Copyright © 2018 Zachary Kipping. All rights reserved.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var name: String?
    @NSManaged public var topic: String?
    @NSManaged public var phone: String?
    @NSManaged public var email: String?
    @NSManaged public var address: String?
    @NSManaged public var rawDate: NSDate?
    @NSManaged public var recordings: NSOrderedSet?

}

// MARK: Generated accessors for recordings
extension Event {

    @objc(insertObject:inRecordingsAtIndex:)
    @NSManaged public func insertIntoRecordings(_ value: Recording, at idx: Int)

    @objc(removeObjectFromRecordingsAtIndex:)
    @NSManaged public func removeFromRecordings(at idx: Int)

    @objc(insertRecordings:atIndexes:)
    @NSManaged public func insertIntoRecordings(_ values: [Recording], at indexes: NSIndexSet)

    @objc(removeRecordingsAtIndexes:)
    @NSManaged public func removeFromRecordings(at indexes: NSIndexSet)

    @objc(replaceObjectInRecordingsAtIndex:withObject:)
    @NSManaged public func replaceRecordings(at idx: Int, with value: Recording)

    @objc(replaceRecordingsAtIndexes:withRecordings:)
    @NSManaged public func replaceRecordings(at indexes: NSIndexSet, with values: [Recording])

    @objc(addRecordingsObject:)
    @NSManaged public func addToRecordings(_ value: Recording)

    @objc(removeRecordingsObject:)
    @NSManaged public func removeFromRecordings(_ value: Recording)

    @objc(addRecordings:)
    @NSManaged public func addToRecordings(_ values: NSOrderedSet)

    @objc(removeRecordings:)
    @NSManaged public func removeFromRecordings(_ values: NSOrderedSet)

}
