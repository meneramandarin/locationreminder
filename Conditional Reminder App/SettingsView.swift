//
//  HotspotView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 06.03.24.
//

import MapKit
import SwiftUI

struct HotspotView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.presentationMode) var presentationMode
  @State private var hotspotName: String = ""
  @State private var hotspots: [Hotspot] = []
  let reminderStorage: ReminderStorage

  init(reminderStorage: ReminderStorage) {
    self.reminderStorage = reminderStorage
    UINavigationBar.appearance().titleTextAttributes = [
      .foregroundColor: UIColor(Color(hex: "FEEBCC"))
    ]
  }

  var body: some View {
    NavigationStack {
      ZStack {
        Color(hex: "023020").edgesIgnoringSafeArea(.all)

        ScrollView {
          VStack {
            Text(
              "Hotspots are places you visit frequently, like your work place or your home. Set up a Hotspot to be able to refer to these places by their name instead of their address."
            )
            .font(.footnote)
            .foregroundColor(Color(hex: "FEEBCC"))
            .padding(.bottom)

            Spacer()

            VStack {
              ForEach(hotspots.indices, id: \.self) { index in
                VStack {
                  HStack {

                    Text(hotspots[index].name)
                      .foregroundColor(Color(hex: "023020"))
                      .padding()

                    Spacer()

                    Button(action: {
                      reminderStorage.deleteHotspot(hotspots[index])
                      loadHotspots()
                    }) {
                      Image(systemName: "xmark.circle")
                        .foregroundColor(Color(hex: "#F4C2C2"))
                    }

                    Spacer()
                      .frame(width: 10)

                  }

                  if index < hotspots.count - 1 {
                    Rectangle()
                      .fill(Color.brown)
                      .frame(height: 1)
                      .padding([.leading, .trailing], 15)
                  }
                }
              }
            }
            .background(Color(hex: "FEEBCC"))
            .cornerRadius(8)

            Spacer()

            NavigationLink(destination: NewHotspot(reminderStorage: reminderStorage)) {

              HStack {
                Text("Add Hotspot")
                Image(systemName: "arrow.right")
              }
              .font(.headline)
              .foregroundColor(Color(hex: "#FFBF00"))
              .padding(.top)

            }
          }
        }
        .padding()
      }
    }
    .navigationBarTitle("Hotspots", displayMode: .inline)  // Set the title
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: {
          presentationMode.wrappedValue.dismiss()
        }) {
          HStack(spacing: 4) {
            Image(systemName: "chevron.left")  // Back arrow for visual clarity
            Text("Menu")
          }
          .foregroundColor(Color(hex: "#FFBF00"))  // Customize Menu color
        }
      }
    }
    .onAppear {
      loadHotspots()
      UINavigationBar.appearance().titleTextAttributes = [
        .foregroundColor: UIColor(Color(hex: "FEEBCC"))
      ]
    }
  }

  private func loadHotspots() {
    hotspots = reminderStorage.fetchHotspots()
  }
}
