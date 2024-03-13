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
    // Additional logic if needed
  }

    func snoozeReminder() {
        /*
        let oneDayComponents = DateComponents(day: 1)
                if let startDate = reminder.startDate {
            reminder.startDate = Calendar.current.date(byAdding: oneDayComponents, to: startDate)
        } else {
            reminder.startDate = Calendar.current.date(byAdding: oneDayComponents, to: Date())
        }
                if let endDate = reminder.endDate {
            reminder.endDate = Calendar.current.date(byAdding: oneDayComponents, to: endDate)
        } else {
            reminder.endDate = Calendar.current.date(byAdding: oneDayComponents, to: Date())
        }
            reminderStorage.updateReminder(reminder)
         
         */
    }

  func editReminder() {
  }

    func loadReminder(withId id: UUID) {
        if let index = reminderStorage.fetchReminders().firstIndex(where: { $0.id == id }) {
            self.reminder = reminderStorage.fetchReminders()[index]
        }
    }
}
        

