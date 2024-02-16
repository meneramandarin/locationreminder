//
//  locationservice.swift
//  Conditional Reminder App
//
//  Created by Marlene on 30.01.24.
//

import CoreLocation
import Foundation

extension Notification.Name {
    static let didUpdateLocation = Notification.Name("didUpdateLocation")
}

class LocationService: NSObject, CLLocationManagerDelegate {
  static let shared = LocationService()

  private let locationManager = CLLocationManager()

  var locationUpdateHandler: ((CLLocation) -> Void)?

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
    guard let location = locations.last else { return }
    // Use the handler to notify about location updates
    locationUpdateHandler?(location)
  }
    
    func broadcastCurrentLocation() {
        guard let location = locationManager.location else { return }
        NotificationCenter.default.post(name: .didUpdateLocation, object: nil, userInfo: ["location": location])
    }
    
  // Implement other delegate methods as necessary
}
