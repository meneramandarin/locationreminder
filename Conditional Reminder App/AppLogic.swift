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
    
    @Published var showReminderDetail = false // property to trigger sheet
    @Published var selectedReminderID: UUID? = nil
    @Published var reminders: [Reminder] = []
    
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
    
     func handleNotificationResponse(with reminderID: UUID) {
        print("Notification received for reminder with ID: \(reminderID)") // works
        if let existingReminder = reminders.first(where: { $0.id == reminderID }) {
            DispatchQueue.main.async {
                self.selectedReminderID = reminderID
                self.showReminderDetail = true
                print("selectedReminderID is now: \(self.selectedReminderID)") // works
                print("showReminderDetail set to: \(self.showReminderDetail)") // works - sheet
            }
        } else {
            print("Reminder with ID \(reminderID) not found locally")
        }
    }
}

extension AppLogic: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification received")
        if let reminderIdString = response.notification.request.content.userInfo["reminderId"] as? String,
           let reminderId = UUID(uuidString: reminderIdString) {
           print("Handling notification for reminder ID: \(reminderId)") // works 
            handleNotificationResponse(with: reminderId)
        } else {
                    print("Could not find reminderId in notification userInfo")
                }
        
        completionHandler()
    }
}
