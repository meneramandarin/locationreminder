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
    func saveReminder(_ reminder: Reminder, completion: @escaping (Result<Void, Error>) -> Void) {
        let newReminder = ReminderItem(context: context)
        newReminder.uuid = reminder.id
        newReminder.locationLatitude = reminder.location.latitude
        newReminder.locationLongitude = reminder.location.longitude
        newReminder.message = reminder.message
        newReminder.startDate = reminder.startDate
        newReminder.endDate = reminder.endDate
        newReminder.snoozeUntil = reminder.snoozeUntil
        newReminder.hotspotName = reminder.hotspotName
        newReminder.locationName = reminder.locationName
        
        print("Saving reminder:")
        print("- Message: \(reminder.message)")
        print("- Start Date: \(reminder.startDate ?? Date())")
        print("- End Date: \(reminder.endDate ?? Date())")
        print("- Location: \(reminder.location)")
        print("- Snooze Until: \(reminder.snoozeUntil ?? Date())")
        print("- Hotspot Name: \(reminder.hotspotName ?? "None")")
        print("- Location Name: \(reminder.locationName ?? "None")")
        
        do {
            try context.save()
            print("Reminder with message '\(reminder.message)' saved successfully.")
            completion(.success(()))
            
            // Notification that reminder has been saved
            NotificationCenter.default.post(name: .reminderAdded, object: nil)
        } catch let error as NSError {
            print("Failed to save reminder: \(error), \(error.userInfo)")
            completion(.failure(error))
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
                reminderToUpdate.locationName = reminder.locationName
                reminderToUpdate.snoozeUntil = reminder.snoozeUntil
                
                processLocationTWO(locationString: reminder.locationName ?? "") { result in
                    switch result {
                        case .success(let coordinate):
                            if let coordinate = coordinate {
                                reminderToUpdate.locationLatitude = coordinate.latitude // Use the correct names
                                reminderToUpdate.locationLongitude = coordinate.longitude
                            } else {
                                // Handle the case where no coordinates were found
                            }
                        case .failure(let error):
                            print("Location conversion error: \(error)")
                    }
                    
                    do {
                        try self.context.save()
                    } catch {
                        print("Error saving reminder: \(error)")
                    }
                } // End of processLocation completion handler
            } // End of if let reminderToUpdate
        } catch {  //  Catch for the top-level do-catch block
            print("Failed to update reminder: \(error)")
        }
    } // End of updateReminder function
    
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
                    endDate: entity.endDate,
                    hotspotName: entity.hotspotName ?? "",
                    locationName: entity.locationName ?? ""
                )
            }
        } catch {
            print("Failed to fetch reminders: \(error)")
            return []
        }
    }
    
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
        
        // Check if there are no more reminders
        if fetchReminders().isEmpty {
            let userDefaults = UserDefaults.standard
            userDefaults.set(true, forKey: "exampleRemindersDeleted")
        }
    }
    
    // Function to delete a reminder after it's done its duty
    func autoDeleteReminder(_ reminder: Reminder) {
        deleteReminder(reminder)
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
    
    // Example Reminders
    func shouldLoadExampleReminders() -> Bool {
        let userDefaults = UserDefaults.standard
        return !userDefaults.bool(forKey: "exampleRemindersDeleted")
    }
    
    func saveExampleReminders() {
        let exampleReminders = [
            Reminder(
                id: UUID(),
                location: CLLocationCoordinate2D(latitude: -37.29846, longitude: -12.67989),
                message: "Checkout Nachtglas Bar",
                startDate: nil,
                endDate: nil,
                hotspotName: "Travel",
                locationName: "Inaccessible Island"
            ),
            Reminder(
                id: UUID(),
                location: CLLocationCoordinate2D(latitude: 41.249612, longitude: -72.751862),
                message: "Withdraw Cash",
                startDate: Date(),
                endDate: Date().addingTimeInterval(360000),
                hotspotName: "Miscellaneous Memos",
                locationName: "Money Island"
            )
        ]
        
        for reminder in exampleReminders {
            saveReminderWithoutNotification(reminder) { result in
                switch result {
                    case .success:
                        print("Example reminder saved successfully.")
                    case .failure(let error):
                        print("Failed to save example reminder: \(error)")
                }
            }
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "exampleRemindersLoaded")
        userDefaults.set(false, forKey: "exampleRemindersDeleted")
    }
    
    // TODO: fuck these functions are a huge libality because when i make any major DB changes they need to change too
    func saveReminderWithoutNotification(_ reminder: Reminder, completion: @escaping (Result<Void, Error>) -> Void) {
        let newReminder = ReminderItem(context: context)
        newReminder.uuid = reminder.id
        newReminder.locationLatitude = reminder.location.latitude
        newReminder.locationLongitude = reminder.location.longitude
        newReminder.message = reminder.message
        newReminder.startDate = reminder.startDate
        newReminder.endDate = reminder.endDate
        newReminder.snoozeUntil = reminder.snoozeUntil
        newReminder.hotspotName = reminder.hotspotName
        newReminder.locationName = reminder.locationName
        
        do {
            try context.save()
            print("Reminder with message '\(reminder.message)' saved successfully.")
            completion(.success(()))
        } catch let error as NSError {
            print("Failed to save reminder: \(error), \(error.userInfo)")
            completion(.failure(error))
        }
    }
    
    func processLocationTWO(locationString: String, completion: @escaping (Result<CLLocationCoordinate2D?, Error>) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationString) { (placemarks, error) in
            if let error = error {
                completion(.failure(error))
            } else if let placemark = placemarks?.first, let location = placemark.location {
                let coordinate = location.coordinate
                completion(.success(coordinate))
            } else {
                completion(.success(nil)) // No location found
            }
        }
    }

    
}
