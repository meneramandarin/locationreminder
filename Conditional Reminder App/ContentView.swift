//
//  ContentView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 15.01.24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        ))
    
    var body: some View {
        VStack {
            // Button to set a new reminder
            NavigationLink(destination: SetReminderView()) {
                Text("Set a new Reminder")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()

            // Your Reminders section title
            Text("Your Reminders:")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            // Example of a reminder entry
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Get off the train")
                            .font(.headline)
                        Text("Tonight, 10 pm")
                            .font(.subheadline)
                    }
                    Spacer()
                    Button(action: {
                        // Action to delete a reminder goes here
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                    }
                }
                
                Map(position: $cameraPosition);
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // You can duplicate the above VStack for each reminder you want to display.
        }
    }
}

// Define a simple struct to represent items on the map - tbh not sure if this has any purpose at this point. works with and without it
struct MapItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
