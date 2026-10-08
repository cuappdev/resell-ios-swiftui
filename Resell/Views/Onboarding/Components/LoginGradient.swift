//
//  LoginGradient.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// The blurred gradient background used on the login screen.
struct LoginGradient: View {

    // MARK: - UI

    var body: some View {
        HStack(spacing: -30) {
            Ellipse()
                .fill(Constants.Colors.resellPurple)
                .frame(width: 650, height: 439)
                .opacity(0.3)
                .blur(radius: 115.56)

            Circle()
                .fill(Constants.Colors.resellBlurGradient)
                .frame(width: 650, height: 650)
                .opacity(0.3)
                .blur(radius: 115.56)
        }
        .padding(.top, UIScreen.height * 0.75)
        .background(Constants.Colors.white)
    }
}
