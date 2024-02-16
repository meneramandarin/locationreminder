//
//  FontExtension.swift
//  Conditional Reminder App
//
//  Created by Marlene on 15.02.24.
//

import SwiftUI

struct AdaptiveFont: ViewModifier {
    var name: String
    var style: UIFont.TextStyle

    func body(content: Content) -> some View {
        content
            .font(.custom(name, size: fontSize(for: style)))
    }

    private func fontSize(for style: UIFont.TextStyle) -> CGFloat {
        let userFont = UIFont.preferredFont(forTextStyle: style)
        return UIFont(name: name, size: userFont.pointSize)?.pointSize ?? userFont.pointSize
    }
}

extension View {
    func adaptiveFont(name: String, style: UIFont.TextStyle) -> some View {
        self.modifier(AdaptiveFont(name: name, style: style))
    }
}

