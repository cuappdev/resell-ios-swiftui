//
//  View+Extensions.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

extension View {

    /// Dismisses the keyboard when the view is tapped.
    func endEditingOnTap() -> some View {
        modifier(EndEditingOnTap())
    }
}

private struct EndEditingOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}
