//
//  SessionLoadingView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// Shown while the previous session is being restored on launch.
struct SessionLoadingView: View {

    // MARK: - UI

    var body: some View {
        ZStack {
            LoginGradient()

            VStack {
                Image("resell")
                    .padding(.top, Constants.SessionLoading.logoTopPadding)

                Text("resell")
                    .font(Constants.Fonts.resellLogo)
                    .foregroundStyle(Constants.Colors.resellGradient)

                Spacer()

                CustomProgressView(size: Constants.SessionLoading.spinnerSize, lineWidth: 4)
                    .padding(.bottom, 80)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SessionLoadingView()
}
