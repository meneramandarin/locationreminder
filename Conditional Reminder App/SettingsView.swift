//
//  SettingsView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 06.03.24.
//

import SwiftUI
import MapKit

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    let reminderStorage: ReminderStorage
                
        init(reminderStorage: ReminderStorage) {
            self.reminderStorage = reminderStorage
        }
    
    @State private var locationQuery: String = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @State private var annotations = [MKPointAnnotation]()
    
    var body: some View {
        VStack {
            Text("Define your hot spots")
                .font(.headline)
            
            VStack {
                Text("Home")
                    .font(.subheadline)
                
                TextField(
                    "Search", text: $locationQuery,
                    onCommit: {
                        LocationService.shared.searchLocation(query: locationQuery) { coordinate in
                            if let coordinate = coordinate {
                                self.region.center = coordinate
                                
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = coordinate
                                self.annotations = [annotation]
                            }
                        }
                    }
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                ReminderMapView(region: $region, annotations: annotations)
                    .frame(height: 300)
                
                Button("Save Home") {
                    let hotspot = Hotspot(name: "Home", location: region.center)
                    reminderStorage.saveHotspot(hotspot)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationBarTitle("Settings")
    }
}
