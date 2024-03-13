//
//  ReminderItem+CoreDataProperties.swift
//  Conditional Reminder App
//
//  Created by Marlene on 12.03.24.
//
//

import Foundation
import CoreData


extension ReminderItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReminderItem> {
        return NSFetchRequest<ReminderItem>(entityName: "ReminderItem")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var locationLatitude: Double
    @NSManaged public var locationLongitude: Double
    @NSManaged public var message: String?
    @NSManaged public var snoozeUntil: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var uuid: UUID?

}

extension ReminderItem : Identifiable {

}
