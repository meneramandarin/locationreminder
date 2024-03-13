//
//  NotifcationHandler.swift
//  Conditional Reminder App
//
//  Created by Marlene on 11.03.24.
//

import Foundation
import UserNotifications

class NotificationHandler: NSObject, ObservableObject {
    static let shared = NotificationHandler()
    private let notificationCenter = UNUserNotificationCenter.current()
    private let reminderStorage = ReminderStorage(context: PersistenceController.shared.container.viewContext)
    
    @Published var showReminderSheet = false
    @Published var selectedReminder: Reminder?
    @Published var selectedReminderID: UUID? = nil
    
    override init() {
        super.init()
        configureNotificationHandling()
    }
    
    func requestNotificationPermission() {
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
    
    func sendNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "We got a Memo for you."
        content.body = reminder.message
        content.sound = UNNotificationSound.default
        content.userInfo = ["reminderId": reminder.id.uuidString]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func handleNotificationResponse(with reminderID: UUID) {
            print("Notification received for reminder with ID: \(reminderID)")
            let reminders = reminderStorage.fetchReminders()
            if let existingReminder = reminders.first(where: { $0.id == reminderID }) {
                DispatchQueue.main.async {
                    self.selectedReminder = existingReminder
                    self.showReminderSheet = true
                    print("showReminderSheet set to: \(self.showReminderSheet)")
                }
            } else {
                print("Reminder with ID \(reminderID) not found locally")
            }
        }
}
    
    extension NotificationHandler: UNUserNotificationCenterDelegate {
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
