//
//  ReminderItem+CoreDataProperties.swift
//  Conditional Reminder App
//
//  Created by Marlene on 30.01.24.
//
//

import Foundation
import CoreData


extension ReminderItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReminderItem> {
        return NSFetchRequest<ReminderItem>(entityName: "ReminderItem")
    }

    @NSManaged public var uuid: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var locationLatitude: Double
    @NSManaged public var locationLongitude: Double
    @NSManaged public var message: String?
    @NSManaged public var snoozeUntil: Date?

}

extension ReminderItem : Identifiable {

}
