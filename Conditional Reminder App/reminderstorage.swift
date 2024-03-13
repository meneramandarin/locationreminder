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

  // Function to save a new reminder
  func saveReminder(_ reminder: Reminder) {
    let newReminder = ReminderItem(context: context)
    newReminder.uuid = UUID()
    newReminder.locationLatitude = reminder.location.latitude
    newReminder.locationLongitude = reminder.location.longitude
    newReminder.message = reminder.message
    newReminder.startDate = reminder.startDate
    newReminder.endDate = reminder.endDate
    newReminder.snoozeUntil = reminder.snoozeUntil
      
    print("Saving reminder:")
    print("- Message: \(reminder.message)")
    print("- Start Date: \(reminder.startDate ?? Date())")
    print("- End Date: \(reminder.endDate ?? Date())")
    print("- Location: \(reminder.location)")
    print("- Snooze Until: \(reminder.snoozeUntil ?? Date())")

    do {
      try context.save()
      print("Reminder with message '\(reminder.message)' saved successfully.")
    } catch let error as NSError {
      print("Failed to save reminder: \(error), \(error.userInfo)")
    }
  }
    
  func updateReminder(_ reminder: Reminder) {
      // Fetch the ReminderItem from Core Data
      let request: NSFetchRequest<ReminderItem> = ReminderItem.fetchRequest()
      request.predicate = NSPredicate(format: "uuid == %@", reminder.id as NSUUID)
      
      do {
          let results = try context.fetch(request)
          if let reminderToUpdate = results.first {
              // Update properties
              reminderToUpdate.message = reminder.message
              reminderToUpdate.startDate = reminder.startDate
              reminderToUpdate.endDate = reminder.endDate
             // reminderToUpdate.latitude = reminder.location.latitude TODO: make locations changable
             // reminderToUpdate.longitude = reminder.location.longitude
              reminderToUpdate.snoozeUntil = reminder.snoozeUntil
              
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
          startDate: entity.startDate,
          endDate: entity.endDate)
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
    
    // functions to save and fetch hotspots
    
    func saveHotspot(_ hotspot: Hotspot) {
        let hotspotItem = hotspot.toHotspotItem(context: context)
        do {
            try context.save()
            print("Hotspot '\(hotspot.name)' saved successfully.")
        } catch {
            print("Failed to save hotspot: \(error)")
        }
    }

    func fetchHotspots() -> [Hotspot] {
        let request: NSFetchRequest<HotspotItem> = HotspotItem.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            return results.map { Hotspot(hotspotItem: $0) }
        } catch {
            print("Failed to fetch hotspots: \(error)")
            return []
        }
    }
    
    func deleteHotspot(_ hotspot: Hotspot) {
        let request: NSFetchRequest<HotspotItem> = HotspotItem.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", hotspot.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            try context.save()
            print("Hotspot '\(hotspot.name)' deleted successfully.")
        } catch {
            print("Failed to delete hotspot: \(error)")
        }
    }
    
    // for searching the right hotspot when saving a new memo
    func findHotspot(with name: String) -> Hotspot? {
        let hotspots = fetchHotspots()
        return hotspots.first { $0.name.lowercased() == name.lowercased() }
    }

}
