//
//  reminderstorage.swift
//  Conditional Reminder App
//
//  Created by Marlene on 29.01.24.
//

import CoreData
import CoreLocation
import Foundation

class ReminderStorage {
  // Reference to managed object context
  let context: NSManagedObjectContext

  init(context: NSManagedObjectContext) {
    self.context = context
  }

  // Function to save a new reminder via the UI
  func saveReminder(_ reminder: Reminder) {
    let newReminder = ReminderItem(context: context)
    newReminder.uuid = UUID()
    newReminder.locationLatitude = reminder.location.latitude
    newReminder.locationLongitude = reminder.location.longitude
    newReminder.message = reminder.message
    newReminder.date = reminder.date
    newReminder.snoozeUntil = reminder.snoozeUntil

    do {
      try context.save()
      print("Reminder with message '\(reminder.message)' saved successfully.")
    } catch let error as NSError {
      print("Failed to save reminder: \(error), \(error.userInfo)")
    }
  }
    
  // Function to update a reminder through Snooze
  func updateReminder(_ reminder: Reminder) {
    // Fetch the ReminderItem from Core Data
   let request: NSFetchRequest<ReminderItem> = ReminderItem.fetchRequest()
   request.predicate = NSPredicate(format: "uuid == %@", reminder.id as NSUUID)

    do {
      let results = try context.fetch(request)
      if let reminderToUpdate = results.first {
        // Update properties
        reminderToUpdate.snoozeUntil = reminder.snoozeUntil
        // Other properties...

        try context.save()
      }
    } catch {
      print("Failed to update reminder: \(error)")
    }
  }

  // Function to fetch all reminders to display them in the UI and also to keep on checking which ones to trigger
  func fetchReminders() -> [Reminder] {
    let request: NSFetchRequest<ReminderItem> = ReminderItem.fetchRequest()

    do {
      let results = try context.fetch(request)
      return results.map { entity in
        Reminder(
          id: entity.uuid ?? UUID(),
          location: CLLocationCoordinate2D(
            latitude: entity.locationLatitude, longitude: entity.locationLongitude),
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
        let request: NSFetchRequest<ReminderItem> = ReminderItem.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", reminder.id as CVarArg)

        do {
            let results = try context.fetch(request)
            if results.isEmpty {
                print("No reminder found with ID: \(reminder.id)")
            } else {
                for object in results {
                    context.delete(object)
                    print("Deleting reminder with ID: \(object.uuid)")
                }
                try context.save()
                print("Successfully deleted reminder and saved context.")
            }
        } catch let error as NSError {
            print("Failed to delete reminder: \(error), \(error.userInfo)")
        }
        // Function to delete a reminder after it's done its duty
        func autoDeleteReminder(_ reminder: Reminder) {
          deleteReminder(reminder)
        }
    }
}

