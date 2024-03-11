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
    @State private var isShowingEditView = false
    
    var body: some View {
        ZStack {
            Color(hex: "023020").edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 20) {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "FEEBCC"))
                .padding()

                // Reminder details
                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.reminder.message)
                        .font(.headline)
                        .foregroundColor(Color(hex: "FEEBCC"))
                    Text(viewModel.reminder.date, style: .date)
                        .foregroundColor(Color(hex: "FEEBCC"))
                    MapView(region: region(for: viewModel.reminder), annotations: [createAnnotation(for: viewModel.reminder)])
                        .frame(height: 200)
                        .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

                HStack {
                    Button("Noted") {
                        viewModel.acknowledgeReminder()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .adaptiveFont(name: "Times New Roman", style: .headline)
                    .foregroundColor(Color(hex: "023020"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "FEEBCC"))
                    .cornerRadius(40)
                    
                    Button("Snooze") {
                        viewModel.snoozeReminder()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .adaptiveFont(name: "Times New Roman", style: .headline)
                    .foregroundColor(Color(hex: "023020"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "FEEBCC"))
                    .cornerRadius(40)
                    
                    Button("Edit") {
                        presentationMode.wrappedValue.dismiss() // Dismiss the sheet
                        self.isShowingEditView = true
                    }
                    .adaptiveFont(name: "Times New Roman", style: .headline)
                    .foregroundColor(Color(hex: "023020"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "FEEBCC"))
                    .cornerRadius(40)
                }
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 30)

                Spacer()
            }
        }
        .sheet(isPresented: $isShowingEditView) {
            SetReminderView(
                reminderToEdit: viewModel.reminder,
                reminders: .constant([]),
                isShowingEditView: $isShowingEditView,
                dismissAction: {
                    self.isShowingEditView = false
                }
            )
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
