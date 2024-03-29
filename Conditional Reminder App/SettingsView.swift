//
//  HotspotView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 06.03.24.
//

import SwiftUI
import MapKit

struct HotspotView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var hotspotName: String = ""
    @State private var hotspots: [Hotspot] = []
    let reminderStorage: ReminderStorage
    
    init(reminderStorage: ReminderStorage) {
        self.reminderStorage = reminderStorage
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color(hex: "FEEBCC"))]
    }
    
    var body: some View {
        NavigationStack {
        ZStack {
            Color(hex: "023020").edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    Text("Hotspots are places you revisit a lot and to which you would rather like to refer by saying “Home” or “Work” instead of repeating the actual address.")
                        .font(.footnote)
                        .foregroundColor(Color(hex: "FEEBCC"))
                    
                    Spacer()
                    
                    ForEach(hotspots) { hotspot in
                        HStack {
                            Text(hotspot.name)
                                .foregroundColor(Color(hex: "023020"))
                            
                            Spacer()
                            
                            Button(action: {
                                reminderStorage.deleteHotspot(hotspot)
                                loadHotspots()
                            }) {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(Color(hex: "#F4C2C2"))
                            }
                        }
                        .background(Color(hex: "FEEBCC"))
                        .cornerRadius(8)
                    }
                    
                    Spacer ()
                
                        NavigationLink(destination: NewHotspot(reminderStorage: reminderStorage)) {
                  
                        HStack {
                            Text("Add Hotspot")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(Color(hex: "#FFBF00"))
                    
                    }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle("Hotspots", displayMode: .inline) // Set the title
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                     HStack(spacing: 4) {
                        Image(systemName: "chevron.left") // Back arrow for visual clarity
                        Text("Menu")
                    }
                    .foregroundColor(Color(hex: "#FFBF00"))  // Customize Menu color
                }
            }
        }
        .onAppear {
            loadHotspots()
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color(hex: "FEEBCC"))]
        }
    }
    
    private func loadHotspots() {
        hotspots = reminderStorage.fetchHotspots()
    }
}
