//
//  ReminderDetailViewModel.swift
//  Conditional Reminder App
//
//  Created by Marlene on 31.01.24.
//

import Foundation
import CoreData
import CoreLocation

class ReminderDetailViewModel: ObservableObject {
    var reminderStorage: ReminderStorage
    @Published var reminder: Reminder

    init(reminder: Reminder, context: NSManagedObjectContext) {
        self.reminder = reminder
        self.reminderStorage = ReminderStorage(context: context)
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

