//
//  ContentView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 15.01.24.
//

// import Combine  // just for testing the timer function
import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
  var region: MKCoordinateRegion
  var annotations: [MKPointAnnotation]
  var gestures: Bool = false

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: false)
        mapView.isZoomEnabled = gestures // Add this line
        mapView.isScrollEnabled = gestures // Add this line
        mapView.isRotateEnabled = gestures // Add this line
        return mapView
    }

  func updateUIView(_ uiView: MKMapView, context: Context) {
    uiView.setRegion(region, animated: true)
    uiView.removeAnnotations(uiView.annotations)  // Clear existing annotations
    uiView.addAnnotations(annotations)  // Add new annotations
  }
}

struct ContentView: View {
  @State private var selectedReminderForEditing: Reminder? // NEW
  @ObservedObject private var voiceInputManager = VoiceInputManager.shared
  @EnvironmentObject var appLogic: AppLogic
  @State private var showLocalAlert: Bool = false
  @State private var reminders: [Reminder] = []  // State variable for reminders
  private let reminderStorage = ReminderStorage(
    context: PersistenceController.shared.container.viewContext)

  var body: some View {
    NavigationView {
      ZStack {
        Color(hex: "023020").edgesIgnoringSafeArea(.all)

        GeometryReader { geometry in
          ScrollView {
            VStack {
              Spacer().frame(height: geometry.size.height / 5)
                NavigationLink(destination: SetReminderView(reminders: $reminders)) {
                Text("New Memory")
                  .padding()
                  .padding(.vertical, 10)
                  .frame(width: UIScreen.main.bounds.width * 0.5)
                  .adaptiveFont(name: "Times New Roman", style: .headline)
                  .background(Color(hex: "FEEBCC"))
                  .foregroundColor(Color(hex: "023020"))
                  .cornerRadius(110)
              }

              
              // Record Button
                
                Button(action: {
                            // Toggle recording
                            voiceInputManager.toggleRecording()
                        }) {
                            Text("Record")
                                .padding()
                                .padding(.vertical, 10)
                                .frame(width: UIScreen.main.bounds.width * 0.5)
                                .adaptiveFont(name: "Times New Roman", style: .headline)
                                .background(voiceInputManager.isRecording ? Color(hex: "#F4C2C2") : Color(hex: "FEEBCC")) // Change color based on isRecording - not visible
                                .foregroundColor(Color(hex: "023020")) // Text color
                                .cornerRadius(110) // Rounded corners
                        }

              Spacer().frame(height: geometry.size.height / 4)

              Text("Your Memories:")
                .adaptiveFont(name: "Times New Roman", style: .headline)
                .foregroundColor(Color(hex: "FEEBCC"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                ForEach(reminders, id: \.id) { reminder in
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(reminder.message)
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "FEEBCC"))
                                Text(reminder.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "FEEBCC"))
                            }
                            Spacer()
                            Button(action: {
                                reminderStorage.deleteReminder(reminder)
                                loadReminders()
                            }) {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(Color(hex: "#F4C2C2"))
                            }
                        }
                        
                        MapView(
                            region: region(for: reminder),
                            annotations: [createAnnotation(for: reminder)],
                            gestures: false
                        )
                        .frame(height: 200)
                        .cornerRadius(10)
                    }
                    .onTapGesture(count: 2) {
                            selectedReminderForEditing = reminder // NEW EDITING
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
          }
        }
      }
      .onAppear {
        loadReminders()
        LocationService.shared.startMonitoringLocation()
        appLogic.start()
        print("ContentView appeared")
      }
      
      // sheet to edit reminder 
          
      .sheet(item: $selectedReminderForEditing) { reminder in
          SetReminderView(reminderToEdit: reminder, reminders: $reminders)
      }


      // TODO: the sheet still doesn't show because selectedReminderID is set to false by @main - i've no idea how to solve it.
      .sheet(isPresented: $appLogic.showReminderDetail) {
        if let reminderId = appLogic.selectedReminderID,
          let selectedReminder = appLogic.reminders.first(where: { $0.id == reminderId })
        {

          ReminderDetailView(
            viewModel: ReminderDetailViewModel(
              reminder: selectedReminder,
              context: PersistenceController.shared.container.viewContext)
          )
          .onDisappear {
            appLogic.showReminderDetail = false
          }

        } else {
          Text("Error: Could not load reminder detail")  // that's what i currently get when i force the sheet with a button
        }
      }
      // MY BEST FRIEND THE SHEET ENDS HERE

    }
  }

  private func loadReminders() {
    reminders = try! reminderStorage.fetchReminders()
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

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
