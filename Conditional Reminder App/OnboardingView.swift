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
                    HStack(spacing: 10) {
                        OnboardingCard(text: "Record Memos:\nTell Memo AI what it\nshould remind you about\n and where or when.")
                            .foregroundColor(DarkGreen)
                        OnboardingCard(text: "For example:\nRemind me to buy\ncandles, when I'm close\nto IKEA.")
                            .foregroundColor(DarkGreen)
                        OnboardingCard(text: "Set Hotspots:\n Define your Home or\nWork place for easier\ninstructions.")
                            .foregroundColor(DarkGreen)
                        OnboardingCard(text: "This unlocks:\nWhen I'm at Work next\nweek I need to buy office\nsupplies.")
                            .foregroundColor(DarkGreen)
                        OnboardingCard(text: "Use natural language:\nRemind me next Week.\nOr, in August, when I’m\nin Spain.")
                            .foregroundColor(DarkGreen)
                        Button(action: {
                            isOnboardingCompleted = true
                        }) {
                            Text("Record your first Memo")
                                .font(.headline)
                                       .foregroundColor(Color(hex: "023020"))
                                       .padding()
                                       .frame(minWidth: 0, maxWidth: .infinity)
                                       .padding(.horizontal, 20)
                                       .padding(.vertical, 10)
                                       .background(Color(hex: "FEEBCC"))
                                       .cornerRadius(25)
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
