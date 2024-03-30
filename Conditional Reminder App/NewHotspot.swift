//
//  NewHotspot.swift
//  Conditional Reminder App
//
//  Created by Marlene on 28.03.24.
//

import SwiftUI
import MapKit

struct NewHotspot: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var locationQuery: String = ""
    @State private var hotspotName: String = ""
    @State private var hotspots: [Hotspot] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @State private var annotations = [MKPointAnnotation]()
    
    let reminderStorage: ReminderStorage
    
    init(reminderStorage: ReminderStorage) {
        self.reminderStorage = reminderStorage
    }


    var body: some View {
        ZStack {
            Color(hex: "023020").edgesIgnoringSafeArea(.all)
            ScrollView {
                    VStack(alignment: .leading) {
                        
                        Spacer()
                        
                        Text("Hotspot Name")
                          .foregroundColor(Color(hex: "FEEBCC"))  // beige
                          .padding([.leading, .trailing, .top])
                        
                        TextField("Hotspot Name", text: $hotspotName)
                            .textFieldStyle(CustomTextFieldStyle())
                            .accentColor(Color(hex: "#FFBF00"))
                            .padding(.horizontal)

                        Text("Where?")
                          .foregroundColor(Color(hex: "FEEBCC"))  // beige
                          .padding([.leading, .trailing, .top])
                        
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
                        .textFieldStyle(CustomTextFieldStyle())
                        .accentColor(Color(hex: "#FFBF00"))
                        .padding(.horizontal)

                        
                        ReminderMapView(region: $region, annotations: annotations)
                            .frame(height: 300)
                            .cornerRadius(8)
                            .padding(.horizontal)

                        
                        Button(action: {
                          let hotspot = Hotspot(name: hotspotName, location: region.center)
                          reminderStorage.saveHotspot(hotspot)
                          hotspotName = ""
                          locationQuery = ""
                          annotations = []
                        }) {
                          HStack {
                            Text("Save Hotspot")
                            Image(systemName: "arrow.right")
                          }
                          .font(.headline)
                          .foregroundColor(Color(hex: "#FFBF00"))
                          .padding([.horizontal, .top])
                          .frame(maxWidth: .infinity, alignment: .center)
                        }
                }
                .padding()
            }
        }
        .navigationBarTitle("New Hotspot", displayMode: .inline)
        .navigationTitle("< Hotspots")
    }
    
    private func loadHotspots() {
        hotspots = reminderStorage.fetchHotspots()
    }
    
}

