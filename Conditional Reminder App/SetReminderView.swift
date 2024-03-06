import MapKit
import SwiftUI

struct ReminderMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var annotations: [MKPointAnnotation]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: true)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations) // Clear existing annotations
        uiView.addAnnotations(annotations) // Add new annotations
    }
}

struct SetReminderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    private var reminderStorage: ReminderStorage {
        ReminderStorage(context: viewContext)
    }
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @State private var reminderText: String = ""
    @State private var selectedDate = Date()
    @State private var locationQuery: String = ""
    @State private var showConfirmationAlert = false
    @State private var annotations = [MKPointAnnotation]() // Added annotations state
    //@State private var confirmationMessage: String = "" // new to have different messages after saving / editing reminder
    @Environment(\.presentationMode) var presentationMode

    var reminderToEdit: Reminder?
    var isEditing: Bool

    init(reminderToEdit: Reminder? = nil) {
        _reminderText = State(initialValue: reminderToEdit?.message ?? "")
        _selectedDate = State(initialValue: reminderToEdit?.date ?? Date())
        self.reminderToEdit = reminderToEdit
        self.isEditing = (reminderToEdit != nil)
    }

    var body: some View {
        ZStack {
            Color(hex: "023020").edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Remind me:")
                        .adaptiveFont(name: "Times New Roman", style: .headline)
                        .foregroundColor(Color(hex: "FEEBCC")) // beige
                        .padding()
                    TextField("Enter reminder details", text: $reminderText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Text("Where?")
                        .adaptiveFont(name: "Times New Roman", style: .headline)
                        .foregroundColor(Color(hex: "FEEBCC")) // beige
                        .padding()
                    TextField(
                        "Search", text: $locationQuery,
                        onCommit: {
                            searchLocation()
                        }
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    ReminderMapView(region: $region, annotations: annotations)
                        .frame(height: 300)
                    Text("When?")
                        .adaptiveFont(name: "Times New Roman", style: .headline)
                        .foregroundColor(Color(hex: "FEEBCC")) // beige
                        .padding()
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .labelsHidden()

                    Button("Set Memory") {
                        let selectedLocation = region.center
                        // Create a new Reminder struct with a new UUID, regardless of editing
                        let newReminder = Reminder(
                            id: UUID(),
                            location: selectedLocation,
                            message: reminderText,
                            date: selectedDate,
                            snoozeUntil: nil // Set this if you have it
                        )
                        reminderStorage.saveReminder(newReminder)
                        showConfirmationAlert = true
                    }
                    .adaptiveFont(name: "Times New Roman", style: .headline)
                    .padding()
                    .frame(maxWidth: .infinity) // Make the button fill the width
                    .background(Color(hex: "FEEBCC")) // Beige color
                    .foregroundColor(Color(hex: "023020")) // Dark green color
                    .cornerRadius(110)
                    .padding(.horizontal)
                    Spacer()
                }
            }
        }
        .navigationTitle("Set a Memory")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showConfirmationAlert) {
            Alert(
                title: Text("Memory Set"),
                message: Text("Your Memory has been set."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss() // Dismiss the view to go back
                }
            )
        }
    }

    // TODO: call this function from locationservice 
    func searchLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationQuery

        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            self.region.center = coordinate

            // Create and update annotation for this location
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.annotations = [annotation] // Reset or set annotations for the map
        }
    }
}

struct SetReminderView_Previews: PreviewProvider {
    static var previews: some View {
        SetReminderView()
    }
}
