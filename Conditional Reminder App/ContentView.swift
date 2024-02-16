/
//  ContentView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 15.01.24.
//
 
import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
  @Binding var region: MKCoordinateRegion

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.setRegion(region, animated: true)
    return mapView
  }

  func updateUIView(_ uiView: MKMapView, context: Context) {
    uiView.setRegion(region, animated: true)
  }
}

struct ContentView: View {
  @State private var reminders: [Reminder] = []  // State variable for reminders
  private let reminderStorage = ReminderStorage(
    context: PersistenceController.shared.container.viewContext)

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "023020").edgesIgnoringSafeArea(.all)

                GeometryReader { geometry in // GeometryReader to read the view's size
                    ScrollView {
                        VStack {
                            Spacer()
                                .frame(height: geometry.size.height / 5) // Push content to 1/4rd of the view's height
                            
                            NavigationLink(destination: SetReminderView()) {
                                Text("New Memory")
                                    .padding()
                                    .padding(.vertical, 10)
                                    .frame(width: UIScreen.main.bounds.width * 0.5) // Set the width to half of the screen's width
                                    .adaptiveFont(name: "Times New Roman", style: .headline)
                                    .background(Color(hex: "FEEBCC")) // Beige color
                                    .foregroundColor(Color(hex: "023020")) // Dark green color
                                    .cornerRadius(110)
                            }
                
                            Spacer()
                                .frame(height: geometry.size.height / 4) // Second spacer to push "Your Memories:" to the lower third. man this is so bad because it's hardcoded and looks cute on my iPhone mini but not elsewhere. need to achieve this rather like this: .padding(.top, geometry.size.height * 0.1) and maybe put the reminders below into their own vstack.
                
                Text("Your Memories:")
                    .adaptiveFont(name: "Times New Roman", style: .headline)
                    .foregroundColor(Color(hex: "FEEBCC")) // beige
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Iterate over the reminders
                ForEach(reminders, id: \.id) { reminder in
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(reminder.message)
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "FEEBCC")) // beige
                                Text(reminder.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "FEEBCC"))
                            }
                            Spacer()
                            Button(action: {
                                print("Delete button tapped for reminder with ID: \(reminder.id)")
                                // Action to delete a reminder
                                reminderStorage.deleteReminder(reminder)
                                // Reload reminders to reflect the change
                                loadReminders()
                            }) {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(Color(hex: "#F4C2C2")) // rose / pink
                            }
                        }
                        
                        // Map view for each reminder
                        MapView(region: .constant(region(for: reminder)))
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
      .onAppear {
        loadReminders()
      }
    }
  }

    private func loadReminders() {
        do {
            reminders = try reminderStorage.fetchReminders()
            for reminder in reminders {
                print("Loaded reminder with ID: \(reminder.id)")
            }
        } catch {
            print("Failed to load reminders: \(error)")
        }
    }

  private func region(for reminder: Reminder) -> MKCoordinateRegion {
    // Create an MKCoordinateRegion based on the reminder's location
    MKCoordinateRegion(
      center: reminder.location,
      span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
