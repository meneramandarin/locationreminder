//
//  ReminderModel.swift
//  Conditional Reminder App
//
//  Created by Marlene on 29.01.24.
//

import CoreLocation
import Foundation

struct Reminder: Identifiable {
  let id: UUID
  let location: CLLocationCoordinate2D
  let message: String
  let date: Date
  var snoozeUntil: Date?

  // Custom initializer
    init(
        id: UUID = UUID(), // Default parameter value is a new UUID, but can be overridden
        location: CLLocationCoordinate2D,
        message: String,
        date: Date,
        snoozeUntil: Date? = nil
      ) {
        self.id = id // Use the passed-in UUID
        self.location = location
        self.message = message
        self.date = date
        self.snoozeUntil = snoozeUntil
      }
    }

extension ReminderItem {
    var asReminderStruct: Reminder {
        // Adjusted to use locationLatitude and locationLongitude
        let locationCoordinate = CLLocationCoordinate2D(
            latitude: self.locationLatitude,
            longitude: self.locationLongitude
        )
        
        return Reminder(
            id: self.uuid ?? UUID(), // Provide a new UUID if nil
            location: locationCoordinate,
            message: self.message ?? "No message", // Provide a default message if nil
            date: self.date ?? Date(), // Provide the current date if nil
            snoozeUntil: self.snoozeUntil // Directly use snoozeUntil, it's already an optional Date
        )
    }
}
