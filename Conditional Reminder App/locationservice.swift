//
//  locationservice.swift
//  Conditional Reminder App
//
//  Created by Marlene on 30.01.24.
//

import CoreLocation
import MapKit
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

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
        // The user has not yet made a choice regarding whether the app can use location services.
        break
    case .restricted, .denied:
        // The user has denied the use of location services for the app or they are restricted.
        // You could alert the user that they need to enable Location Services for your app.
        break
    case .authorizedWhenInUse, .authorizedAlways:
        // The app is authorized to use location services.
        startMonitoringLocation()
        break
    @unknown default:
        fatalError("Unhandled authorization status: \(status)")
    }
  }

  // Implement other delegate methods as necessary
    
    // Add the searchLocation function
        func searchLocation(query: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            
            let search = MKLocalSearch(request: request)
            search.start { response, _ in
                guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                    completion(nil)
                    return
                }
                completion(coordinate)
            }
        }
}
