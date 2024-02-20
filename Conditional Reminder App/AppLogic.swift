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

class AppLogic: ObservableObject {
    private let locationService = LocationService.shared
    private let reminderStorage: ReminderStorage
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init(reminderStorage: ReminderStorage) {
        self.reminderStorage = reminderStorage
        configureLocationService()
        requestNotificationPermission()
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
    
    private func requestNotificationPermission() {
            notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Notification permission granted.")
                } else if let error = error {
                    print("Notification permission error: \(error)")
                }
            }
        }
    
    private func checkRemindersNearLocation(_ currentLocation: CLLocation) {
        let reminders = reminderStorage.fetchReminders()
        for reminder in reminders {
            // Check if the reminder is snoozed.
            if let snoozeUntil = reminder.snoozeUntil, snoozeUntil > Date() {
                // If the reminder is snoozed, skip this iteration and proceed with the next reminder.
                continue
            }

            // If the reminder is not snoozed, proceed to check its proximity.
            let reminderLocation = CLLocation(latitude: reminder.location.latitude, longitude: reminder.location.longitude)
            if currentLocation.distance(from: reminderLocation) <= 1000 { // 1km range
                sendNotification(for: reminder)
            }
        }
    }
        
        func sendNotification(for reminder: Reminder) {
            let content = UNMutableNotificationContent()
            content.title = "Reminder"
            content.body = reminder.message
            content.sound = UNNotificationSound.default
            content.userInfo = ["reminderId": reminder.id.uuidString]  // Add reminder ID
            
            // Trigger the notification immediately
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
