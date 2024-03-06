//
//  Conditional_Reminder_AppApp.swift
//  Conditional Reminder App
//
//  Created by Marlene on 15.01.24.
//

import SwiftUI

@main
struct Conditional_Reminder_AppApp: App {
    // Access the shared PersistenceController
    let persistenceController = PersistenceController.shared
    
    @StateObject var appLogic: AppLogic
    
    init() {
        // Initialize ReminderStorage with the PersistenceController's context
        let reminderStorage = ReminderStorage(context: PersistenceController.shared.context)
        
        // Set the ReminderStorage instance for GPTapiManager
        GPTapiManager.shared.reminderStorage = reminderStorage
        
        // Initialize AppLogic with ReminderStorage and set it as a StateObject
        _appLogic = StateObject(wrappedValue: AppLogic(reminderStorage: reminderStorage))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Provide the managed object context to the ContentView
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // Provide the AppLogic environment object to the ContentView
                .environmentObject(appLogic)
        }
    }
}
