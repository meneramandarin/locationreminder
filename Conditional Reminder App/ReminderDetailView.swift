//
//  ReminderDetailView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 17.01.24.
//

import SwiftUI
import MapKit

struct ReminderDetailView: View {
    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        ))
    @Environment(\.presentationMode) var presentationMode
    @State private var isEditing = false // State to control navigation
    // var reminder: Reminder - use this once you got logic coded
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button("Back") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            
            // Reminder details
            VStack(alignment: .leading, spacing: 10) {
                Text("Get off the train") // (reminder.title) hard coded now, use logic later
                    .font(.title)
                Text("Tonight, 10 pm") // (reminder.date???) hard coded
                // fake location below
                Map(position: $cameraPosition) 
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal)

            // Action buttons
            Button("Okay") {
                // Action to dismiss the reminder
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(ActionButtonStyle())

            Button("Snooze") {
                // Action to snooze the reminder
            }
            .buttonStyle(ActionButtonStyle())

            Button("Edit") {
                // Set isEditing to true to navigate to SetReminderView
                self.isEditing = true
            }
            .buttonStyle(ActionButtonStyle())
            .padding(.bottom, 30)

            Spacer()
        }
        //activate code below for when testing on iphone
        //.navigationDestination(isPresented: $isEditing) {
                      //  SetReminderView()
    }
}

// Custom button style for the action buttons
struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

struct ReminderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderDetailView() // Simply instantiate without passing a Reminder object
                    // .previewDevice("iPhone 13 Mini") // Ensure you're previewing on the correct device
        // Here's the reminder logic
        //ReminderDetailView(reminder: Reminder(title: "Get off the train", time: Date()))
    }
}

