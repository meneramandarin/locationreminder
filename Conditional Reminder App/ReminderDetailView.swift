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
  @State private var isEditing = false

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
        // real location below
        /*Map(
          position: .constant(
            MapCameraPosition.region(
              MKCoordinateRegion(
                center: viewModel.reminder.location,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
              ))))
         */
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

      Button("Edit") {
        // Set isEditing to true to navigate to SetReminderView
        self.isEditing = true
      }
      .buttonStyle(ActionButtonStyle())
      .padding(.bottom, 30)
      .sheet(isPresented: $isEditing) {
        SetReminderView(reminderToEdit: viewModel.reminder)
      }

      Spacer()
    }
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
