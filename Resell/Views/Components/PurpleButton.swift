//
//  PurpleButton.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// Resell's primary capsule button, with loading, disabled, and alert styling.
struct PurpleButton: View {

    // MARK: - Properties

    var isLoading: Bool = false
    var isActive: Bool = true
    var isAlert: Bool = false
    let text: String
    var horizontalPadding: CGFloat = 48
    let action: () -> Void

    // MARK: - UI

    var body: some View {
        Button {
            if isActive && !isLoading { action() }
        } label: {
            label
                .opacity(isActive ? 1.0 : 0.4)
        }
        .disabled(!isActive || isLoading)
    }

    private var label: some View {
        HStack(spacing: 12) {
            if isLoading {
                CustomProgressView(color: Constants.Colors.white, size: 20, lineWidth: 4)
            }

            Text(text)
                .font(Constants.Fonts.title1)
                .foregroundStyle(Constants.Colors.white)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, 14)
        .background(isAlert ? Constants.Colors.errorRed : Constants.Colors.resellPurple)
        .clipShape(.capsule)
    }
}
