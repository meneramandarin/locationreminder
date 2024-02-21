//
//  ReminderDetailViewModel.swift
//  Conditional Reminder App
//
//  Created by Marlene on 31.01.24.
//

import CoreData
import CoreLocation
import Foundation

public class ReminderDetailViewModel: ObservableObject {
    var reminderStorage: ReminderStorage
    @Published var reminder: Reminder

    init(reminder: Reminder, context: NSManagedObjectContext) {
        self.reminder = reminder
        self.reminderStorage = ReminderStorage(context: context)
    }

    func loadReminder(withId id: UUID) {
        // Assuming fetchReminders() fetches all reminders and then filters them to find the one with the matching ID.
        let allReminders = reminderStorage.fetchReminders()
        if let fetchedReminder = allReminders.first(where: { $0.id == id }) {
            self.reminder = fetchedReminder
        }
    }

    func acknowledgeReminder() {
        reminderStorage.deleteReminder(reminder)
        // Additional logic if needed
    }

    func snoozeReminder() {
        let snoozeEndDate = Calendar.current.date(byAdding: .hour, value: 24, to: Date())
        reminder.snoozeUntil = snoozeEndDate
        // Update the reminder in the storage
        reminderStorage.updateReminder(reminder)
    }

    func editReminder() {
        // Implement edit logic
        // This might involve navigating to SetReminderView with the current reminder details
    }
}
        
      // TODO: Optimize reminder fetching by ID
      // Currently, this method fetches all reminders and filters them in memory to find the one matching a specific ID.
      // This approach may lead to performance issues as the number of reminders grows.
      // For a more efficient solution, consider implementing a dedicated method in the ReminderStorage class
      // that directly queries and fetches a reminder by its UUID from the underlying storage (e.g., Core Data, SQLite, etc.).
      // Example method signature in ReminderStorage: func fetchReminder(by id: UUID) -> Reminder?
      // This will minimize memory usage and improve the performance of fetching individual reminders.

