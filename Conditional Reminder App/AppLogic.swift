//
//  AppLogic.swift
//  Conditional Reminder App
//
//  Created by Marlene on 30.01.24.
//

// Currently only location based TODO: date based 

import Foundation
import CoreLocation
import UserNotifications
import Combine

class AppLogic: NSObject, ObservableObject {
    static let shared = AppLogic(reminderStorage: ReminderStorage(context: PersistenceController.shared.container.viewContext))
    private let locationService = LocationService.shared
    private let reminderStorage: ReminderStorage
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var reminders: [Reminder] = []
    
     init(reminderStorage: ReminderStorage) {
            self.reminderStorage = reminderStorage
            super.init() // Call to super.init() is required because we are now subclassing NSObject
            configureLocationService()
            NotificationHandler.shared.requestNotificationPermission()
        }
    
    private func configureLocationService() {
        locationService.locationUpdateHandler = { [weak self] location in
            self?.checkRemindersNearLocation(location)
        }
    }
    
    func start() {
        locationService.startMonitoringLocation()
    }
    
    func stop() {
        locationService.stopMonitoringLocation()
    }
    
    private func checkRemindersNearLocation(_ currentLocation: CLLocation) {
        let reminders = reminderStorage.fetchReminders()

        AppLogic.shared.reminders = reminders // Update reminders using shared instance

        for reminder in reminders {
            if let snoozeUntil = reminder.snoozeUntil, snoozeUntil > Date() {
                continue
            }

            let reminderLocation = CLLocation(latitude: reminder.location.latitude, longitude: reminder.location.longitude)
            if currentLocation.distance(from: reminderLocation) <= 1000, // 1km range
                whatTime(reminder) {
                sendNotification(for: reminder)
            }
        }
    }
    
    // checks time - this can turn into a whole rabbit hole in and of itself wrt optimization, because in should reasonably only check if the date is close and otherwise pause, kinda like nested geofencing ... and well opening hours of stores *cries* - here
    private func whatTime(_ reminder: Reminder) -> Bool {
            let currentDate = Date()

            // Check if start and end dates are defined
            if let startDate = reminder.startDate, let endDate = reminder.endDate {
                return startDate <= currentDate && currentDate <= endDate
            } else if let startDate = reminder.startDate { // Single date check
                return Calendar.current.isDate(currentDate, inSameDayAs: startDate)
            } else {
                return true // No time restriction, trigger always
            }
        }
    
    func sendNotification(for reminder: Reminder) {
            NotificationHandler.shared.sendNotification(for: reminder) // Call the sendNotification method from NotificationHandler
        }
}

