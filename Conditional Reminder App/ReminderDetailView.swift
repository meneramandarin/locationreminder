//
//  ReminderDetailView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 17.01.24.
//

import CoreLocation
import MapKit
import SwiftUI

struct ReminderDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ReminderDetailViewModel
    
    var body: some View {
        ZStack {
            Color(hex: "023020").edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 20) {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()

                // Reminder details
                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.reminder.message)
                        .font(.title)
                    Text(viewModel.reminder.date, style: .date)
                    // Updated map view with annotation
                    MapView(region: region(for: viewModel.reminder), annotations: [createAnnotation(for: viewModel.reminder)])
                        .frame(height: 200)
                        .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

                // Action buttons
                Button("Noted") {
                    viewModel.acknowledgeReminder()
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(ActionButtonStyle())

                Button("Snooze") {
                    viewModel.snoozeReminder()
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(ActionButtonStyle())

                /* Button("Edit") {
                    // Set isEditing to true to navigate to SetReminderView
                    self.isEditing = true
                }
                .buttonStyle(ActionButtonStyle())
                .padding(.bottom, 30)
                 */

                Spacer()
            }
        }
    }

    private func region(for reminder: Reminder) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: reminder.location,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    }

    private func createAnnotation(for reminder: Reminder) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = reminder.location
        annotation.title = reminder.message
        return annotation
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
