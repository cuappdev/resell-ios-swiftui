//
//  CustomProgressView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// A continuously spinning three-quarter ring, used in place of the system spinner.
struct CustomProgressView: View {

    // MARK: - Properties

    var color: Color = Constants.Colors.resellPurple
    var size: CGFloat = 100
    var lineWidth: CGFloat = 8

    @State private var isAnimating = false

    // MARK: - UI

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(color, lineWidth: lineWidth)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear { isAnimating = true }
    }
}
