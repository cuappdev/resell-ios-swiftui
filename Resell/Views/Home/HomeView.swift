//
//  HomeView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

struct HomeView: View {

    // MARK: - Properties

    @State private var viewModel = ViewModel()

    // MARK: - UI

    var body: some View {
        content
            .background(Constants.Colors.white)
            .navigationTitle("Recent Listings")
            .navigationDestinations()
            .task {
                if case .loading = viewModel.state { await viewModel.load() }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            CustomProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            message("No listings yet.")
        case .error(let text):
            errorState(text)
        case .loaded(let posts):
            feed(posts)
        }
    }

    private func feed(_ posts: [Post]) -> some View {
        ScrollView {
            ProductGalleryView(posts: posts) { post in
                Task { await viewModel.loadMoreIfNeeded(currentItem: post) }
            }
            .padding(.top, 12)
        }
        .refreshable { await viewModel.refresh() }
    }

    private func errorState(_ text: String) -> some View {
        VStack(spacing: 16) {
            message(text)
            PurpleButton(text: "Try Again", horizontalPadding: 40) {
                Task { await viewModel.load() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .font(Constants.Fonts.body1)
            .foregroundStyle(Constants.Colors.secondaryGray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
