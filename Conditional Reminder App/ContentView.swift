//
//  ContentView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 15.01.24.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @State private var isShowingEditView = false // manual input button
    @State private var isToggleOn = false // for toggle
    @State private var showMenu = false // for bullet menu
    @State private var isOnboardingCompleted = UserDefaults.standard.bool(forKey: "isOnboardingCompleted") // Onboarding flow
    @StateObject private var notificationHandler = NotificationHandler.shared  // new for sheet
    @State private var reminderDetailViewModel: ReminderDetailViewModel?
    @State private var showReminderAddedMessage = false  // update + notification for reminder has been set
    @State private var selectedReminderForEditing: Reminder?
    @EnvironmentObject var appLogic: AppLogic
    @State private var showLocalAlert: Bool = false
    @State private var reminders: [Reminder] = []  // State variable for reminders
    private let reminderStorage = ReminderStorage(
        context: PersistenceController.shared.container.viewContext)
    
    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color(hex: "FFBF00"))
        }
    
    var hotspotGroups: [HotspotGroup] {
       let groupedReminders = Dictionary(grouping: reminders, by: { $0.hotspotName ?? "No Hotspot" })
       return groupedReminders.map { HotspotGroup(name: $0.key, reminders: $0.value) }
     }
    
    var body: some View {
      if isOnboardingCompleted {
        NavigationView { // TODO: wrap into MainAppView()
          ZStack {
            Color(hex: "023020").edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
              ScrollView {
                VStack {
                  Spacer().frame(height: geometry.size.height / 5)
                    
                    VStack {
                        
                        if isToggleOn {
                            
                            RecordButtonView()
                            
                        } else  {
                            
                            NavigationLink(destination: SetReminderView(reminders: $reminders, isShowingEditView: $isShowingEditView, dismissAction: {
                                // Perform any necessary actions when the view is dismissed
                            })) {
                                HStack {
                                        Image(systemName: "square.and.pencil") // SF Symbol for microphone
                                            .font(.title) // Adjust the size of the icon as needed
                                        Text("Memo")
                                        .adaptiveFont(name: "Times New Roman", style: .title1)
                                    }
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .frame(width: UIScreen.main.bounds.width * 0.5, height: 100)
                                .background(Color(hex: "FEEBCC"))
                                .foregroundColor(Color(hex: "023020"))
                                .cornerRadius(110)
                            }

                            
                        }
                        HStack(spacing: 4) {  // Adjust the spacing to control how tight the text and toggle are squeezed together
                            Text("Memo AI")
                            Toggle("", isOn: $isToggleOn)
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "FEEBCC")))
                                .labelsHidden()  // This ensures there's no extra padding for a non-existent label
                            Text("")
                                
                        }
                        .padding()
                    }
                    
                  
                  Spacer().frame(height: geometry.size.height / 4)
                  
                  ForEach(hotspotGroups, id: \.name) { group in
                    Section(header: Text(group.name)
                      .font(.headline)
                      .foregroundColor(Color(hex: "FEEBCC"))
                      .padding(.horizontal)
                    ) {
                      ForEach(group.reminders, id: \.id) { reminder in
                        VStack(alignment: .leading) {
                          HStack {
                            VStack(alignment: .leading) {
                              Text(reminder.message)
                                .font(.headline)
                                .foregroundColor(Color(hex: "FEEBCC"))
                                
                                Text(reminder.locationName ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "FEEBCC"))
                              
                              ReminderDateView(reminder: reminder)
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
            }
          }
          .onAppear {
                  loadReminders()
                  LocationService.shared.startMonitoringLocation()
                  appLogic.start()
                  print("ContentView appeared")
              
              // example reminders
              if reminderStorage.shouldLoadExampleReminders() {
                      let userDefaults = UserDefaults.standard
                      if !userDefaults.bool(forKey: "exampleRemindersLoaded") {
                          reminderStorage.saveExampleReminders()
                          loadReminders()
                      }
                  }
              
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
                    dismissButton: 
                        .default(Text("Oki, thx, bye."))
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
                    ReminderDetailView(
                      viewModel: ReminderDetailViewModel(
                        reminder: reminder, context: PersistenceController.shared.container.viewContext))
                  }
                }
                .navigationBarItems(
                                trailing:
                                    Button(action: {
                                        showMenu.toggle()
                                    }) {
                                        Image(systemName: "ellipsis")
                                    }
                                    .accentColor(Color(hex: "#FFBF00"))
                            )
                        }
                        .sheet(isPresented: $showMenu) {
                            BulletMenuView()
                        }
            
      } else {
          // Show the onboarding view
          OnboardingView(isOnboardingCompleted: $isOnboardingCompleted)
              .onDisappear {
                  UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
              }
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

          struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
              ContentView()
            }
          }
    }

// additional structs

struct BulletMenuView: View {
    private let reminderStorage = ReminderStorage(
        context: PersistenceController.shared.container.viewContext)
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: HotspotView(reminderStorage: reminderStorage)) {
                    Text("Hotspots")
                        .foregroundColor(Color(hex: "FEEBCC"))
                }
                .listRowBackground(Color(hex: "023020"))
                .navigationTitle("Menu")
                
                NavigationLink(destination: AboutView()) {
                    Text("About")
                        .foregroundColor(Color(hex: "FEEBCC"))
                }
                .listRowBackground(Color(hex: "023020"))
                .navigationTitle("Menu")

            }
            .listStyle(PlainListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Menu")
                        .font(.title)
                        .foregroundColor(Color(hex: "FEEBCC"))
                }
            }
            .background(Color(hex: "023020"))
            .scrollContentBackground(.hidden)
        }
        .accentColor(Color(hex: "FEEBCC"))
    }
}

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

struct HotspotGroup {
  let name: String
  let reminders: [Reminder]
}

struct RecordButtonView: View {

  @ObservedObject private var voiceInputManager = VoiceInputManager.shared
  @State private var isAnimating = false

  var body: some View {
    Button(action: {
      voiceInputManager.toggleRecording()
      withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
        isAnimating = voiceInputManager.isRecording
      }
    }) {
        HStack {
                Image(systemName: "mic") // SF Symbol for microphone
                    .font(.title) // Adjust the size of the icon as needed
                Text("Memo")
                .adaptiveFont(name: "Times New Roman", style: .title1)
            }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .frame(width: UIScreen.main.bounds.width * 0.5, height: 100)
        .background(voiceInputManager.isRecording ? Color(hex: "#F4C2C2") : Color(hex: "FEEBCC"))
        .foregroundColor(Color(hex: "023020"))
        .cornerRadius(110)
        .scaleEffect(isAnimating ? 1.1 : 1.0)
    }
  }
}

struct ReminderDateView: View {
  let reminder: Reminder
  
  var body: some View {
    if let startDate = reminder.startDate {
      if let endDate = reminder.endDate {
        if startDate == endDate {
          Text(formatDate(startDate))
            .font(.subheadline)
            .foregroundColor(Color(hex: "FEEBCC"))
        } else {
          Text("\(formatDate(startDate)) - \(formatDate(endDate))")
            .font(.subheadline)
            .foregroundColor(Color(hex: "FEEBCC"))
        }
      } else {
        Text(formatDate(startDate))
          .font(.subheadline)
          .foregroundColor(Color(hex: "FEEBCC"))
      }
    } else if let endDate = reminder.endDate {
      Text(formatDate(endDate))
        .font(.subheadline)
        .foregroundColor(Color(hex: "FEEBCC"))
    } else {
      Text("Whenever 🤷")
        .font(.subheadline)
        .foregroundColor(Color(hex: "FEEBCC"))
    }
  }
    
    private func formatDate(_ date: Date) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM d, yyyy"
      return dateFormatter.string(from: date)
    }
  }
