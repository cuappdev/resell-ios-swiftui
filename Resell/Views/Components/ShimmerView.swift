//
//  ShimmerView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// A placeholder that sweeps a soft highlight across itself while content loads.
struct ShimmerView: View {

    // MARK: - Properties

    @State private var phase: CGFloat = -1

    // MARK: - UI

    var body: some View {
        Constants.Colors.wash
            .overlay {
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [.clear, Constants.Colors.white.opacity(0.6), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width)
                    .offset(x: phase * geometry.size.width)
                }
            }
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}
