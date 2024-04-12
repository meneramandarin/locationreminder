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

  func acknowledgeReminder() {
    reminderStorage.deleteReminder(reminder)
  }

    func snoozeReminder() {
        let updatedReminder = Reminder(
            id: reminder.id,
            location: reminder.location,
            message: reminder.message,
            startDate: nil,
            endDate: nil,
            snoozeUntil: reminder.snoozeUntil,
            locationName: reminder.locationName
        )
        reminder = updatedReminder
        reminderStorage.updateReminder(updatedReminder)
    }

    func loadReminder(withId id: UUID) {
        if let index = reminderStorage.fetchReminders().firstIndex(where: { $0.id == id }) {
            self.reminder = reminderStorage.fetchReminders()[index]
        }
    }
}
        

