//
//  ReminderModel.swift
//  Conditional Reminder App
//
//  Created by Marlene on 29.01.24.
//

import Foundation
import CoreLocation

struct Reminder {
    let location: CLLocationCoordinate2D
    let message: String
    let date: Date
}
