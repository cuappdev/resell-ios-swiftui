//
//  ProductDetailView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// Minimal product detail — a placeholder landing screen for the gallery's navigation.
/// The full detail (image carousel, seller, save, contact) lands in a later increment.
struct ProductDetailView: View {

    // MARK: - Properties

    let post: Post

    // MARK: - UI

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CachedImageView(url: post.firstImageURL)
                    .frame(height: 320)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(.rect(cornerRadius: 12))

                Text(post.title)
                    .font(Constants.Fonts.h2)
                    .foregroundStyle(Constants.Colors.black)

                Text("$\(post.originalPrice)")
                    .font(Constants.Fonts.h3)
                    .foregroundStyle(Constants.Colors.resellPurple)

                Text(post.detailsLabel)
                    .font(Constants.Fonts.body2)
                    .foregroundStyle(Constants.Colors.secondaryGray)

                Text(post.description)
                    .font(Constants.Fonts.body2)
                    .foregroundStyle(Constants.Colors.black)
            }
            .padding(Constants.Spacing.horizontalPadding)
        }
        .background(Constants.Colors.white)
        .navigationBarTitleDisplayMode(.inline)
    }
}
