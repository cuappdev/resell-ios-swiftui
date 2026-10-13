//
//  MainView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// The signed-in container: each tab owns its own `NavigationStack`, with a custom floating
/// glass tab bar (the default `TabView` bar flickers under the redesigned screens).
struct MainView: View {

    // MARK: - Properties

    @State private var selectedTab: Tab = .home

    enum Tab: CaseIterable {
        case home, messages, profile

        var icon: String {
            switch self {
            case .home: "home"
            case .messages: "messages"
            case .profile: "user"
            }
        }

        var label: String {
            switch self {
            case .home: "Home"
            case .messages: "Messages"
            case .profile: "Profile"
            }
        }
    }

    // MARK: - UI

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Color.clear.frame(height: 56)
                }

            tabBar
        }
        .background(Constants.Colors.white)
    }

    private var tabContent: some View {
        ZStack {
            tab(.home) { HomeView() }
            tab(.messages) { MessagesView() }
            tab(.profile) { ProfileView() }
        }
    }

    private func tab(_ tab: Tab, @ViewBuilder root: () -> some View) -> some View {
        NavigationStack { root() }
            .opacity(selectedTab == tab ? 1 : 0)
            .allowsHitTesting(selectedTab == tab)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .modifier(TabBarGlassModifier())
        .contentShape(Capsule())
        .padding(.horizontal, 40)
        .padding(.bottom, 8)
    }

    private func tabButton(for tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(isSelected ? "\(tab.icon)-selected" : tab.icon)
                    .renderingMode(.original)

                Text(tab.label)
                    .font(Constants.Fonts.subtitle1)
                    .foregroundStyle(isSelected ? Constants.Colors.resellPurple : Constants.Colors.secondaryGray)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Floating glass capsule behind the tab bar, with a material fallback before iOS 26.
private struct TabBarGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        let shape = Capsule()
        if #available(iOS 26, *) {
            content.glassEffect(.regular, in: shape)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.strokeBorder(Constants.Colors.black.opacity(0.06), lineWidth: 1))
                .shadow(color: Constants.Colors.black.opacity(0.08), radius: 8, y: 2)
        }
    }
}

#Preview {
    MainView()
        .environmentObject(MainView.ViewModel())
}
