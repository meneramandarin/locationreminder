//
//  OnboardingView.swift
//  Conditional Reminder App
//
//  Created by Marlene on 25.03.24.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingCompleted: Bool
    let backgroundColor = Color(hex: "023020")
    let cardColor = Color(hex: "FEEBCC")
    let skipButtonColor = Color(hex: "FFBF00")
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Memo")
                    .adaptiveFont(name: "Times New Roman", style: .headline)
                    .foregroundColor(cardColor)
                    .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        OnboardingCard(text: "Record memos\nTell Memo AI what\nit should remind\nyou about & when.")
                        OnboardingCard(text: "For example:\nRemind me to\nbuy candles when\nI'm close to IKEA.")
                        OnboardingCard(text: "Set Hotspots:\n Define your Home or Work place\nfor easier instructions.")
                        OnboardingCard(text: "This unlocks:\nWhen I'm at Work\nnext week\nI need to buy office supplies.")
                    }
                    .padding()
                }
                
                Button(action: {
                    isOnboardingCompleted = true // THIS IS NOT THE RIGHT WAY TO HANDLE THIS
                    // Handle skip button action
                }) {
                    Text("Skip")
                        .foregroundColor(skipButtonColor)
                }
                .padding()
            }
        }
    }
}

struct OnboardingCard: View {
    let text: String
    let cardColor = Color(hex: "FEEBCC")
    
    var body: some View {
        VStack {
            Text(text)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .frame(width: 200, height: 300)
        .background(cardColor)
        .cornerRadius(10)
    }
}

 // TODO: use the @AppStorage property wrapper to store a boolean value indicating whether the onboarding has been completed.

