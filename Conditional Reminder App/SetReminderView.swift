//
//  SetReminderView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 17.01.24.
//

import SwiftUI
import MapKit

struct SetReminderView: View {
    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        ))
    @State private var reminderText: String = ""
    @State private var selectedDate = Date()
    @State private var locationQuery: String = ""
    @State private var showConfirmationAlert = false
    @Environment(\.presentationMode) var presentationMode // This is used to dismiss the view

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Button("Back") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                .padding(.top, 70)
            }
            .padding()

            Text("Remind me:")
                .font(.headline)
            TextField("Enter reminder details", text: $reminderText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Text("Where?")
                .font(.headline)
            TextField("Search", text: $locationQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Map(position: $cameraPosition)
            Text("When?")
                .font(.headline)
            Text("Select a date")
                    .foregroundColor(.secondary)
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .labelsHidden()

            Button("Set reminder") {
                // Action to save the reminder
                showConfirmationAlert = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
            .alert(isPresented: $showConfirmationAlert) {
                            Alert(
                                title: Text("Reminder Set"),
                                message: Text("Your reminder has been set."),
                                dismissButton: .default(Text("OK")) {
                                    presentationMode.wrappedValue.dismiss() // Dismiss the view to go back
                                }
                            )
                        }
            Spacer()
        }
        .padding(.leading, 20)
        .navigationTitle("Set a Reminder")
    }
}

struct SetReminderView_Previews: PreviewProvider {
    static var previews: some View {
        SetReminderView()
    }
}
