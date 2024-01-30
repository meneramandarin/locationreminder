//
//  ReminderEntity+CoreDataProperties.swift
//  Conditional Reminder App
//
//  Created by Marlene on 29.01.24.
//
//

import Foundation
import CoreData


extension ReminderEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReminderEntity> {
        return NSFetchRequest<ReminderEntity>(entityName: "ReminderEntity")
    }

    @NSManaged public var locationLatitude: Double
    @NSManaged public var locationLongitude: Double
    @NSManaged public var message: String?
    @NSManaged public var date: Date?

}

extension ReminderEntity : Identifiable {

}
