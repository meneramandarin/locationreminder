//
//  ContentView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 15.01.24.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
  var region: MKCoordinateRegion
  var annotations: [MKPointAnnotation]
  var gestures: Bool = false

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: false)
        mapView.isZoomEnabled = gestures
        mapView.isScrollEnabled = gestures
        mapView.isRotateEnabled = gestures
        return mapView
    }

  func updateUIView(_ uiView: MKMapView, context: Context) {
    uiView.setRegion(region, animated: true)
    uiView.removeAnnotations(uiView.annotations)
    uiView.addAnnotations(annotations)
  }
}

struct ContentView: View {
  @StateObject private var notificationHandler = NotificationHandler.shared // new for sheet
  @State private var reminderDetailViewModel: ReminderDetailViewModel?
  @State private var showReminderAddedMessage = false // update + notification for reminder has been set
  @State private var isAnimating = false // record button animation
  @State private var selectedReminderForEditing: Reminder?
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
              
                /*
                
                NavigationLink(destination: SetReminderView(reminders: $reminders)) {
                Text("New Memo")
                  .padding()
                  .padding(.vertical, 10)
                  .frame(width: UIScreen.main.bounds.width * 0.5)
                  .adaptiveFont(name: "Times New Roman", style: .headline)
                  .background(Color(hex: "FEEBCC"))
                  .foregroundColor(Color(hex: "023020"))
                  .cornerRadius(110)
              }
                 
               */
                 
              // Record Button only
                
                Button(action: {
                            voiceInputManager.toggleRecording()
                            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                isAnimating = voiceInputManager.isRecording
                            }
                        }) {
                            Text("Record Memo")
                                .padding()
                                .padding(.vertical, 10)
                                .frame(width: UIScreen.main.bounds.width * 0.5)
                                .adaptiveFont(name: "Times New Roman", style: .headline)
                                .background(voiceInputManager.isRecording ? Color(hex: "#F4C2C2") : Color(hex: "FEEBCC"))
                                .foregroundColor(Color(hex: "023020")) // Text color
                                .cornerRadius(110)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                        }
                
              Spacer().frame(height: geometry.size.height / 4)

              Text("Your Memos:")
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
                            selectedReminderForEditing = reminder
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
      // refresh for new memo set
      .onReceive(NotificationCenter.default.publisher(for: .reminderAdded)) { _ in
              showReminderAddedMessage = true
              loadReminders()
          }
          .alert(isPresented: $showReminderAddedMessage) {
              Alert(
                  title: Text("Memo Added"),
                  message: Text("We got your memo!"),
                  dismissButton: .default(Text("Oki, thx, bye."))
              )
          }
        
        // sheet to edit reminder
        .sheet(item: $selectedReminderForEditing) { reminder in
            SetReminderView(
                reminderToEdit: reminder,
                reminders: $reminders,
                isShowingEditView: .constant(true),
                dismissAction: {
                    selectedReminderForEditing = nil
                    NotificationCenter.default.post(name: .reminderAdded, object: nil)
                }
            )
        }

        // new sheet
        .sheet(isPresented: $notificationHandler.showReminderSheet) {
            if let reminder = notificationHandler.selectedReminder {
                ReminderDetailView(viewModel: ReminderDetailViewModel(reminder: reminder, context: PersistenceController.shared.container.viewContext))
            }
        }
        
        // Hotspots
      .navigationBarItems(trailing:
                  NavigationLink(destination: SettingsView(reminderStorage: reminderStorage)) {
                      Text("Hotspots")
                  }
              .accentColor(Color(hex: "#FEEBCC"))
              )
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
