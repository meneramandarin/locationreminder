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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
