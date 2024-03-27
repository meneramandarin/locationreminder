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
  let startDate: Date?
  let endDate: Date?
  var snoozeUntil: Date?
  let hotspotName: String?
  let locationName: String? // TODO: ? because if hotspotName location name can stay empty

  // Custom initializer
    init(
        id: UUID = UUID(), // Default parameter value is a new UUID, but can be overridden
        location: CLLocationCoordinate2D,
        message: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        snoozeUntil: Date? = nil,
        hotspotName: String? = nil,
        locationName: String? = nil // change from just String no questions asked lol 
      ) {
        self.id = id // Use the passed-in UUID
        self.location = location
        self.message = message
        self.startDate = startDate
        self.endDate = endDate
        self.snoozeUntil = snoozeUntil
        self.hotspotName = hotspotName ?? ""
        self.locationName = locationName ?? "" // change from just locationName
      }
    }
