//
//  colorextension.swift
//  Conditional Reminder App
//
//  Created by Marlene on 15.02.24.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")).uppercased()
        let hexValue: UInt64 = {
            var hexVal: UInt64 = 0
            Scanner(string: hexString).scanHexInt64(&hexVal)
            return hexVal
        }()
        
        let red = Double((hexValue & 0xFF0000) >> 16) / 255.0
        let green = Double((hexValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(hexValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
