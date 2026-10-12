//
//  MainView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// The signed-in container: a tab bar where each tab owns its own `NavigationStack`.
struct MainView: View {

    // MARK: - Properties

    @EnvironmentObject private var viewModel: ViewModel

    // MARK: - UI

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", image: "home") }

            NavigationStack {
                profileTab
            }
            .tabItem { Label("Profile", image: "user") }
        }
        .tint(Constants.Colors.resellPurple)
    }

    // MARK: - Profile (placeholder)

    private var profileTab: some View {
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
        .navigationTitle("Profile")
    }
}

#Preview {
    MainView()
        .environmentObject(MainView.ViewModel())
}
