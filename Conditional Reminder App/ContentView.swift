//
//  ContentView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 15.01.24.
//

import MapKit
import SwiftUI
import CoreData

struct MapView: UIViewRepresentable {
  var region: MKCoordinateRegion
  var annotations: [MKPointAnnotation]

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.setRegion(region, animated: true)
    return mapView
  }

  func updateUIView(_ uiView: MKMapView, context: Context) {
    uiView.setRegion(region, animated: true)
    uiView.removeAnnotations(uiView.annotations)  // Clear existing annotations
    uiView.addAnnotations(annotations)  // Add new annotations
  }
}

struct ContentView: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @EnvironmentObject var appLogic: AppLogic
  @State private var reminders: [Reminder] = []  // State variable for reminders
  @State private var selectedReminderUUID: UUID?
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

              NavigationLink(destination: SetReminderView()) {
                Text("New Memory")
                  .padding()
                  .padding(.vertical, 10)
                  .frame(width: UIScreen.main.bounds.width * 0.5)
                  .adaptiveFont(name: "Times New Roman", style: .headline)
                  .background(Color(hex: "FEEBCC"))
                  .foregroundColor(Color(hex: "023020"))
                  .cornerRadius(110)
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
                    region: region(for: reminder), annotations: [createAnnotation(for: reminder)]
                  )
                  .frame(height: 200)
                  .cornerRadius(10)
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
      .sheet(item: $appLogic.selectedReminderID) { reminderId in // Update to .sheet(item:)
                  if let reminder = fetchReminder(by: reminderId, using: managedObjectContext) {
                      ReminderDetailView(viewModel: ReminderDetailViewModel(reminder: reminder, context: managedObjectContext))
                  } else {
                      Text("Reminder not found")
                  }
              }
      .onAppear {
        loadReminders()
        LocationService.shared.startMonitoringLocation()
        appLogic.start()
        appLogic.checkForNotificationTrigger()
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
    
    func fetchReminder(by reminderId: IdentifiableUUID, using context: NSManagedObjectContext) -> Reminder? {
        let fetchRequest: NSFetchRequest<ReminderItem> = ReminderItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", reminderId.id as CVarArg) // Update predicate to use reminderId.id

        do {
            let results = try context.fetch(fetchRequest)
            return results.first?.asReminderStruct // Assuming you have a conversion method
        } catch {
            print("Error fetching reminder: \(error)")
            return nil
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
