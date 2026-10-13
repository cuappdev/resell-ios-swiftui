//
//  MainView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// The signed-in container: a tab bar where each tab owns its own `NavigationStack`.
struct MainView: View {

    // MARK: - UI

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", image: "home") }

            NavigationStack {
                MessagesView()
            }
            .tabItem { Label("Messages", image: "messages") }

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", image: "user") }
        }
        .tint(Constants.Colors.resellPurple)
    }
}

#Preview {
    MainView()
        .environmentObject(MainView.ViewModel())
}
