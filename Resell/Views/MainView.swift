//
//  MainView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// The signed-in home surface. A placeholder for this increment — onboarding is the focus;
/// the real tab bar and feature tabs land in a later rewrite step.
struct MainView: View {

    // MARK: - Properties

    @EnvironmentObject private var viewModel: ViewModel

    // MARK: - UI

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("resell")
                .font(Constants.Fonts.resellLogo)
                .foregroundStyle(Constants.Colors.resellGradient)

            Text("You're signed in.")
                .font(Constants.Fonts.body1)
                .foregroundStyle(Constants.Colors.secondaryGray)

            Spacer()

            PurpleButton(text: "Log out", horizontalPadding: 60) {
                viewModel.logout()
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Constants.Colors.white)
    }
}

#Preview {
    MainView()
        .environmentObject(MainView.ViewModel())
}
