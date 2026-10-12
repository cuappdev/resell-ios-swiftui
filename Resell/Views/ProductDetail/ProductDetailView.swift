//
//  ProductDetailView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

struct ProductDetailView: View {

    // MARK: - Properties

    /// The listing passed from the feed — shown immediately, then superseded by the
    /// VM's full refetch once it arrives.
    let post: Post

    @State private var viewModel = ViewModel()
    @State private var currentImage = 0

    private var displayed: Post { viewModel.fullPost ?? post }

    // MARK: - UI

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                imageCarousel

                VStack(alignment: .leading, spacing: 16) {
                    titleAndPrice
                    detailsLabel

                    Divider()
                    sellerRow

                    Divider()
                    descriptionSection
                }
                .padding(.horizontal, Constants.Spacing.horizontalPadding)
            }
            .padding(.bottom, 24)
        }
        .background(Constants.Colors.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { saveButton }
        }
        .task { await viewModel.load(post) }
        .errorAlert($viewModel.errorMessage)
    }

    private var imageCarousel: some View {
        TabView(selection: $currentImage) {
            ForEach(Array(displayed.images.enumerated()), id: \.offset) { index, urlString in
                CachedImageView(url: URL(string: urlString))
                    .clipped()
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .frame(height: 360)
        .overlay {
            if displayed.isSold { soldBadge }
        }
    }

    private var soldBadge: some View {
        ZStack {
            Constants.Colors.black.opacity(0.5)
            Text("Item Sold")
                .font(Constants.Fonts.h2)
                .foregroundStyle(Constants.Colors.white)
        }
    }

    private var titleAndPrice: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(displayed.title)
                .font(Constants.Fonts.h2)
                .foregroundStyle(Constants.Colors.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("$\(displayed.originalPrice)")
                .font(Constants.Fonts.h2)
                .foregroundStyle(Constants.Colors.resellPurple)
        }
    }

    private var detailsLabel: some View {
        Text(displayed.detailsLabel)
            .font(Constants.Fonts.body2)
            .foregroundStyle(Constants.Colors.secondaryGray)
    }

    @ViewBuilder
    private var sellerRow: some View {
        if let user = displayed.user {
            HStack(spacing: 12) {
                CachedImageView(url: user.photoUrl)
                    .frame(width: 40, height: 40)
                    .clipShape(.circle)

                Text(user.displayName)
                    .font(Constants.Fonts.title2)
                    .foregroundStyle(Constants.Colors.black)

                Spacer()
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(Constants.Fonts.title1)
                .foregroundStyle(Constants.Colors.black)

            Text(displayed.description)
                .font(Constants.Fonts.body2)
                .foregroundStyle(Constants.Colors.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var saveButton: some View {
        Button {
            viewModel.toggleSaved(for: displayed)
        } label: {
            Image(systemName: viewModel.isSaved ? "bookmark.fill" : "bookmark")
                .foregroundStyle(Constants.Colors.resellPurple)
        }
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(post: .mock)
    }
}
