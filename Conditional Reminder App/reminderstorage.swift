//
//  reminderstorage.swift
//  Conditional Reminder App
//
//  Created by Marlene on 29.01.24.
//

import Foundation
import CoreData
import CoreLocation

class ReminderStorage {
    // Reference to managed object context
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // Function to save a new reminder
    func saveReminder(_ reminder: Reminder) {
        let newReminder = ReminderEntity(context: context)
        newReminder.locationLatitude = reminder.location.latitude
        newReminder.locationLongitude = reminder.location.longitude
        newReminder.message = reminder.message
        newReminder.date = reminder.date

        do {
            try context.save()
        } catch {
            print("Failed to save reminder: \(error)")
        }
    }

    // Function to fetch all reminders to display them in the UI and also to keep on checking which ones to trigger
    func fetchReminders() -> [Reminder] {
        let request: NSFetchRequest<ReminderEntity> = ReminderEntity.fetchRequest()

        do {
            let results = try context.fetch(request)
            return results.map { entity in
                Reminder(location: CLLocationCoordinate2D(latitude: entity.locationLatitude, longitude: entity.locationLongitude),
                         message: entity.message ?? "",
                         date: entity.date ?? Date())
            }
        } catch {
            print("Failed to fetch reminders: \(error)")
            return []
        }
    }

    // Function to delete a reminder
    func deleteReminder(_ reminder: Reminder) {
        let request: NSFetchRequest<ReminderEntity> = ReminderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "message == %@ AND date == %@", reminder.message, reminder.date as CVarArg)

        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            try context.save()
        } catch {
            print("Failed to delete reminder: \(error)")
        }
    }

    // Function to delete a reminder after it's done its duty
    func autoDeleteReminder(_ reminder: Reminder) {
        deleteReminder(reminder)
    }
}
