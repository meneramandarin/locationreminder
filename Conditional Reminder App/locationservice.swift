//
//  locationservice.swift
//  Conditional Reminder App
//
//  Created by Marlene on 30.01.24.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()

    private let locationManager = CLLocationManager()

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        // Additional configuration for locationManager
    }

    func startMonitoringLocation() {
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }

    func stopMonitoringLocation() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Handle location updates
        // Notify AppLogic.swift if a significant location change matches a reminder
    }
    
    // Implement other delegate methods as necessary
}

