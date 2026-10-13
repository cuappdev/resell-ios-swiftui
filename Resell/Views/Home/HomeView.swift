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
    @State private var showNewListing = false
    @State private var showFilter = false

    // MARK: - UI

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                shopByCategory
                forYou
                recentListings
            }
            .padding(.top, 12)
            .padding(.bottom, 80)
        }
        .background(Constants.Colors.white)
        .safeAreaInset(edge: .top, spacing: 0) { topBar }
        .overlay(alignment: .bottomTrailing) {
            FloatingActionButton { showNewListing = true }
        }
        .fullScreenCover(isPresented: $showNewListing) {
            NavigationStack { NewListingView() }
        }
        .sheet(isPresented: $showFilter) {
            FilterView(homeViewModel: viewModel)
        }
        .navigationDestinations()
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if case .loading = viewModel.state { await viewModel.load() }
            await viewModel.loadSaved()
        }
        .refreshable { await viewModel.refresh() }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Image("resellText")
                .resizable()
                .scaledToFit()
                .frame(height: 28)

            Spacer()

            HStack(spacing: 20) {
                NavigationLink(value: Route.search) {
                    icon("search")
                }

                Button {} label: {
                    icon("bell")
                }
            }
            .foregroundStyle(Constants.Colors.black)
        }
        .padding(.horizontal, Constants.Spacing.horizontalPadding)
        .padding(.vertical, 12)
        .background(Constants.Colors.white)
    }

    private func icon(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: 26, height: 26)
    }

    // MARK: - Shop By Category

    private var shopByCategory: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Shop By Category")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Constants.Listing.categories, id: \.self) { category in
                        NavigationLink(value: Route.category(category)) {
                            CategoryCircleView(name: category)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Constants.Spacing.horizontalPadding)
            }
        }
    }

    // MARK: - For You (Saved)

    private var forYou: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("For You")

            if viewModel.savedPosts.isEmpty {
                emptySavedCard
                    .padding(.horizontal, Constants.Spacing.horizontalPadding)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(viewModel.savedPosts) { post in
                            NavigationLink(value: Route.productDetail(post)) {
                                ProductCardView(post: post)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Constants.Spacing.horizontalPadding)
                }
            }
        }
    }

    private var emptySavedCard: some View {
        VStack(spacing: 4) {
            Text("You haven't saved any listings yet.")
            HStack(spacing: 4) {
                Text("Tap")
                Image(systemName: "bookmark")
                Text("on a listing to save.")
            }
        }
        .font(Constants.Fonts.body1)
        .foregroundStyle(Constants.Colors.secondaryGray)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(32)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Constants.Colors.stroke, lineWidth: 1)
        }
    }

    // MARK: - Recent Listings

    private var recentListings: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Listings")
                    .font(Constants.Fonts.h2)
                    .foregroundStyle(Constants.Colors.black)

                Spacer()

                Button { showFilter = true } label: {
                    Image("filters")
                        .renderingMode(viewModel.isFiltered ? .template : .original)
                        .foregroundStyle(viewModel.isFiltered ? Constants.Colors.resellPurple : Constants.Colors.black)
                }
            }
            .padding(.horizontal, Constants.Spacing.horizontalPadding)

            feedContent
        }
    }

    @ViewBuilder
    private var feedContent: some View {
        switch viewModel.state {
        case .loading:
            CustomProgressView(size: 36)
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
        case .empty:
            message("No listings yet.")
        case .error(let text):
            message(text)
        case .loaded(let posts):
            ProductGalleryView(posts: posts) { post in
                Task { await viewModel.loadMoreIfNeeded(currentItem: post) }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Constants.Fonts.h2)
            .foregroundStyle(Constants.Colors.black)
            .padding(.horizontal, Constants.Spacing.horizontalPadding)
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .font(Constants.Fonts.body1)
            .foregroundStyle(Constants.Colors.secondaryGray)
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
