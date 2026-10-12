//
//  ErrorAlert.swift
//  Resell
//
//  Created by jiwon jeong on 10/11/26.
//

import SwiftUI

/// Presents a one-button alert whenever a VM's `errorMessage` is non-nil, then clears it.
/// Apply with `.errorAlert($viewModel.errorMessage)` so every screen surfaces errors the same way.
struct ErrorAlert: ViewModifier {

    @Binding var message: String?

    func body(content: Content) -> some View {
        content.alert(
            "Something went wrong",
            isPresented: Binding(
                get: { message != nil },
                set: { if !$0 { message = nil } }
            )
        ) {
            Button("OK", role: .cancel) { message = nil }
        } message: {
            Text(message ?? "")
        }
    }
}

extension View {
    func errorAlert(_ message: Binding<String?>) -> some View {
        modifier(ErrorAlert(message: message))
    }
}
