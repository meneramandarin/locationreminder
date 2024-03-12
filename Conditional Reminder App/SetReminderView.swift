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
        uiView.addAnnotations(annotations)
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
    @State private var annotations = [MKPointAnnotation]()
    @State private var confirmationMessage: String = "" // to have different messages after saving / editing reminder
    @Binding var reminders: [Reminder]
    @Binding var isShowingEditView: Bool
    @Environment(\.presentationMode) var presentationMode

    var reminderToEdit: Reminder?
    var isEditing: Bool
    var dismissAction: () -> Void

    init(reminderToEdit: Reminder? = nil, reminders: Binding<[Reminder]>, isShowingEditView: Binding<Bool>, dismissAction: @escaping () -> Void) {
            _reminderText = State(initialValue: reminderToEdit?.message ?? "")
            _selectedDate = State(initialValue: reminderToEdit?.date ?? Date())
            self.reminderToEdit = reminderToEdit
            self.isEditing = (reminderToEdit != nil)
            self._reminders = reminders
            self._isShowingEditView = isShowingEditView
            self.dismissAction = dismissAction
        }

    var body: some View {
        ZStack {
            Color(hex: "023020").edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("What is your Memo about?")
                        .foregroundColor(Color(hex: "FEEBCC")) // beige
                        .padding()
                    TextField("Enter reminder details", text: $reminderText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Text("Where?")
                        .foregroundColor(Color(hex: "FEEBCC")) // beige
                        .padding()
                    TextField(
                        "Search", text: $locationQuery,
                        onCommit: {
                            LocationService.shared.searchLocation(query: locationQuery) { coordinate in
                                if let coordinate = coordinate {
                                    self.region.center = coordinate
                                    
                                    // Create and update annotation for this location
                                    let annotation = MKPointAnnotation()
                                    annotation.coordinate = coordinate
                                    self.annotations = [annotation] // Reset or set annotations for the map
                                }
                            }
                        }
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    ReminderMapView(region: $region, annotations: annotations)
                        .frame(height: 300)
                    Text("When?")
                        .foregroundColor(Color(hex: "FEEBCC")) // beige
                        .padding()
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .accentColor(Color(hex: "#FFBF00")) // Amber color
                        .padding()
                        .labelsHidden()

                    Button("Set Memo") {
                                let selectedLocation = region.center
                                
                                if isEditing, let reminderToEdit = reminderToEdit {
                                    // Update the existing reminder
                                    let updatedReminder = Reminder(
                                        id: reminderToEdit.id,
                                        location: selectedLocation,
                                        message: reminderText,
                                        date: selectedDate,
                                        snoozeUntil: nil // Set this if you have it
                                    )
                                    reminderStorage.updateReminder(updatedReminder)
                                    confirmationMessage = "We updated your Memo."
                                    // Update the reminders array
                                    if let index = reminders.firstIndex(where: { $0.id == updatedReminder.id }) {
                                        reminders[index] = updatedReminder
                                    }
                                } else {
                                    // Create a new reminder
                                    let newReminder = Reminder(
                                        id: UUID(),
                                        location: selectedLocation,
                                        message: reminderText,
                                        date: selectedDate,
                                        snoozeUntil: nil // Set this if you have it
                                    )
                                    reminderStorage.saveReminder(newReminder)
                                    confirmationMessage = "We set a new Memo."
                                }
                                showConfirmationAlert = true // Show the confirmation alert
                                NotificationCenter.default.post(name: .reminderAdded, object: nil) // Notify ContentView to update
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
        .navigationTitle("Save Memo")
        .accentColor(Color(hex: "#FFBF00")) // Amber color for the back button
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showConfirmationAlert) {
            Alert(
                title: Text(confirmationMessage),
                dismissButton: .default(Text("Oki, thx, bye.")) {
                    dismissAction()
                }
            )
        }
    }
}

struct SetReminderView_Previews: PreviewProvider {
    static var previews: some View {
        SetReminderView(
            reminders: .constant([]),
            isShowingEditView: .constant(false),
            dismissAction: {}
        )
    }
}
