//
//  AboutView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 29.03.24.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        ZStack {
            Color(hex: "023020").edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                
                Text("Memo")
                    .font(.custom("Times New Roman", size: 100))
                    .foregroundColor(Color(hex: "FEEBCC"))
                    .padding()
                
                let MadebyText = "Memo is an experiment made by \n[Play by Ear](https://www.playbyear.xyz)."
                Text(.init(MadebyText))
                    .foregroundColor(Color(hex: "FEEBCC"))
                    .accentColor(Color(hex: "FFBF00"))
                
                Spacer()
                
            }
            .navigationBarTitle("About", displayMode: .inline)
            .navigationTitle("< Menu")
        }
    }
}
