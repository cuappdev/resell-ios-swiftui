//
//  ProfileView.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import SwiftUI

struct ProfileView: View {

    // MARK: - Properties

    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @State private var viewModel = ViewModel()

    // MARK: - UI

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                tabBar
                tabContent
            }
            .padding(.top, 16)
        }
        .background(Constants.Colors.white)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestinations()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { optionsMenu }
        }
        .refreshable { await viewModel.refresh(viewModel.selectedTab) }
        .task(id: viewModel.selectedTab) { await viewModel.load(viewModel.selectedTab) }
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        if let user = viewModel.user {
            VStack(spacing: 12) {
                CachedImageView(url: user.photoUrl)
                    .frame(width: 100, height: 100)
                    .clipShape(.circle)

                Text(user.displayName)
                    .font(Constants.Fonts.h2)
                    .foregroundStyle(Constants.Colors.black)

                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(Constants.Fonts.body2)
                        .foregroundStyle(Constants.Colors.secondaryGray)
                        .multilineTextAlignment(.center)
                }

                statsRow(for: user)
            }
            .padding(.horizontal, Constants.Spacing.horizontalPadding)
        }
    }

    private func statsRow(for user: User) -> some View {
        HStack(spacing: 24) {
            stat(value: user.stars, label: "Rating")
            stat(value: "\(user.soldPosts ?? 0)", label: "Sold")
            stat(value: "\(user.numReviews)", label: "Reviews")
        }
        .padding(.top, 4)
    }

    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(Constants.Fonts.title1)
                .foregroundStyle(Constants.Colors.black)
            Text(label)
                .font(Constants.Fonts.subtitle1)
                .foregroundStyle(Constants.Colors.secondaryGray)
        }
    }

    // MARK: - Tabs

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(ViewModel.Tab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, Constants.Spacing.horizontalPadding)
    }

    private func tabButton(for tab: ViewModel.Tab) -> some View {
        let isSelected = viewModel.selectedTab == tab
        return Button {
            viewModel.selectedTab = tab
        } label: {
            VStack(spacing: 6) {
                Text(tab.rawValue)
                    .font(Constants.Fonts.title3)
                    .foregroundStyle(isSelected ? Constants.Colors.black : Constants.Colors.secondaryGray)

                Rectangle()
                    .fill(isSelected ? Constants.Colors.resellPurple : .clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Content

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.state {
        case .loading:
            CustomProgressView(size: 36)
                .padding(.top, 60)
        case .empty:
            message("Nothing here yet.")
        case .error(let text):
            message(text)
        case .loaded(let posts):
            ProductGalleryView(posts: posts) { _ in }
        }
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .font(Constants.Fonts.body1)
            .foregroundStyle(Constants.Colors.secondaryGray)
            .padding(.top, 60)
    }

    // MARK: - Options

    private var optionsMenu: some View {
        Menu {
            Button("Log out", role: .destructive) {
                mainViewModel.logout()
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(Constants.Colors.black)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(MainView.ViewModel())
    }
}
