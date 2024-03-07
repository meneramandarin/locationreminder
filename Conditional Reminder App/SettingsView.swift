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
    
    @State private var locationQuery: String = ""
    @State private var hotspotName: String = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @State private var annotations = [MKPointAnnotation]()
    @State private var hotspots: [Hotspot] = []
    
    let reminderStorage: ReminderStorage
    
    init(reminderStorage: ReminderStorage) {
        self.reminderStorage = reminderStorage
    }
    
    var body: some View {
        ZStack {
            Color(hex: "023020").edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    Text("Set a new Hotspot like your home or work")
                        .adaptiveFont(name: "Times New Roman", style: .headline)
                        .foregroundColor(Color(hex: "FEEBCC"))
                    
                    VStack {
                        TextField("Hotspot Name", text: $hotspotName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField(
                            "Search Location", text: $locationQuery,
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
                        
                        Button("Save") {
                            let hotspot = Hotspot(name: hotspotName, location: region.center)
                            reminderStorage.saveHotspot(hotspot)
                            hotspotName = ""
                            locationQuery = ""
                            annotations = []
                        }
                        .adaptiveFont(name: "Times New Roman", style: .headline)
                        .foregroundColor(Color(hex: "023020"))
                        .padding()
                        .background(Color(hex: "FEEBCC"))
                        .cornerRadius(40)
                    }
                    .padding()
                    
                    Text("Your Hotspots")
                        .adaptiveFont(name: "Times New Roman", style: .headline)
                        .foregroundColor(Color(hex: "FEEBCC"))
                    
                    ForEach(hotspots) { hotspot in
                        HStack {
                            Text(hotspot.name)
                                .adaptiveFont(name: "Times New Roman", style: .headline)
                                .foregroundColor(Color(hex: "FEEBCC"))
                            
                            Spacer()
                            
                            Button(action: {
                                reminderStorage.deleteHotspot(hotspot)
                                loadHotspots()
                            }) {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(Color(hex: "#F4C2C2"))
                            }
                        }
                        Spacer()
                            .frame(height: 20)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle("Settings")
        .onAppear {
            loadHotspots()
        }
    }
    
    private func loadHotspots() {
        hotspots = reminderStorage.fetchHotspots()
    }
}
