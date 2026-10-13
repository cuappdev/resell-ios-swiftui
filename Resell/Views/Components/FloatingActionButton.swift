//
//  FloatingActionButton.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import SwiftUI

/// The gradient "+" button that floats over Home and Profile to start a new listing.
struct FloatingActionButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(Constants.Colors.resellGradient)
                .frame(width: Constants.Home.fabSize, height: Constants.Home.fabSize)
                .background(Constants.Colors.white)
                .clipShape(.circle)
                .overlay {
                    Circle().strokeBorder(Constants.Colors.resellGradient, lineWidth: 2)
                }
                .shadow(color: Constants.Colors.black.opacity(0.15), radius: 6, y: 3)
        }
        .padding(.trailing, Constants.Spacing.horizontalPadding)
        .padding(.bottom, 16)
    }
}
