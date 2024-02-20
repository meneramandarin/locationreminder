//
//  Conditional_Reminder_AppApp.swift
//  Conditional Reminder App
//
//  Created by Marlene on 15.01.24.
//

import SwiftUI

@main
struct Conditional_Reminder_AppApp: App {
    let persistenceController = PersistenceController.shared
    
    // Initialize AppLogic with the ReminderStorage instance
    @StateObject var appLogic: AppLogic
    
    init() {
         let reminderStorage = ReminderStorage(context: persistenceController.container.viewContext)
         _appLogic = StateObject(wrappedValue: AppLogic(reminderStorage: reminderStorage))
     }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appLogic)
        }
    }
}
