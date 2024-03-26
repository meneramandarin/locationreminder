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
    let DarkGreen = Color(hex: "023020")
    let Beige = Color(hex: "FEEBCC")
    let Amber = Color(hex: "FFBF00")
    
    var body: some View {
        ZStack {
            DarkGreen.edgesIgnoringSafeArea(.all)
            
            VStack {
                
                HStack {
                        Spacer()  // Push the button to the right
                        Button(action: {
                            isOnboardingCompleted = true
                        }) {
                            Text("Skip")
                                .foregroundColor(Amber)
                        }
                        .padding()
                    }
                
                Spacer()
                
                Text("Memo")
                    .font(.custom("Times New Roman", size: 100))
                    .foregroundColor(Beige)
                    .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        OnboardingCard(icon: "mic", text: "Record Memos:\nTell Memo AI what it\nshould remind you about,\n and where to do so.")
                        OnboardingCard(icon: "building.2", text: "For example:\nRemind me to buy\ncandles, when I'm close\nto an IKEA.")
                        OnboardingCard(icon: "pin", text: "Set Hotspots:\n Define your Home or\nWork place for easier\ninstructions.")
                        OnboardingCard(icon: "bolt", text: "This unlocks:\n'When I'm at Work next\nweek, I need to buy office\nsupplies.'")
                        OnboardingCard(icon: "person.wave.2", text: "Use natural language:\n'Remind me in a couple\n of days.' Or, 'in August, when\nI’m in Spain.'")
                        
                        Button(action: {
                            isOnboardingCompleted = true
                        }) {
                            HStack {
                                Text("Record your first Memo")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(Amber)
                        }
                    }
                    .foregroundColor(DarkGreen)
                    .padding()
                }
                
                Spacer()
                
            }
        }
    }
}

struct OnboardingCard: View {
    let icon: String
    let text: String
    let DarkGreen = Color(hex: "023020")
    let Beige = Color(hex: "FEEBCC")
    let Amber = Color(hex: "FFBF00")
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(DarkGreen)
                .padding()
            
            Text(text)
                .foregroundColor(DarkGreen)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
        }
        .frame(width: 300, height: 200)
        .background(Beige)
        .cornerRadius(10)
    }
}
