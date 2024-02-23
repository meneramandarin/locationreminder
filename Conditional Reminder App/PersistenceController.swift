//
//  PersistenceController.swift
//  Conditional Reminder App
//
//  Created by Marlene on 30.01.24.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    var context: NSManagedObjectContext {
        return container.viewContext
    }

    init() {
        container = NSPersistentContainer(name: "ReminderModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            // Print the location of the CoreData SQLite file
            if let url = self.container.persistentStoreDescriptions.first?.url {
                print("Database Location: \(url)")
            }
        }
    }
}
