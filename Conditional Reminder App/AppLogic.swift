//
//  AppLogic.swift
//  Conditional Reminder App
//
//  Created by Marlene on 30.01.24.
//

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
            if currentLocation.distance(from: reminderLocation) <= 1000 { // 1km range
                sendNotification(for: reminder)
            }
        }
    }
    
    func sendNotification(for reminder: Reminder) {
            NotificationHandler.shared.sendNotification(for: reminder) // Call the sendNotification method from NotificationHandler
        }
}

