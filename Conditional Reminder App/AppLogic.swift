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
    private let locationService = LocationService.shared
    private let reminderStorage: ReminderStorage
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var selectedReminderID: UUID? // For navigating to the specific reminder detail view
    
     init(reminderStorage: ReminderStorage) {
            self.reminderStorage = reminderStorage
            super.init() // Call to super.init() is required because we are now subclassing NSObject
            configureLocationService()
            requestNotificationPermission()
            configureNotificationHandling()
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
    
    private func configureNotificationHandling() {
        notificationCenter.delegate = self
    }
    
    private func checkRemindersNearLocation(_ currentLocation: CLLocation) {
        let reminders = reminderStorage.fetchReminders()
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
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = reminder.message
        content.sound = UNNotificationSound.default
        content.userInfo = ["reminderId": reminder.id.uuidString]  // Add reminder ID
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func handleNotificationResponse(with reminderID: UUID) {
        // Update the selectedReminderID to trigger navigation in your SwiftUI view hierarchy
        DispatchQueue.main.async {
            self.selectedReminderID = reminderID
        }
    }
}

extension AppLogic: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let reminderIdString = response.notification.request.content.userInfo["reminderId"] as? String,
           let reminderId = UUID(uuidString: reminderIdString) {
            handleNotificationResponse(with: reminderId)
        }
        
        completionHandler()
    }
}
