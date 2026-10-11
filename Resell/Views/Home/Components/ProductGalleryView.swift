//
//  ProductGalleryView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// A two-column staggered gallery of listings. `onReachEnd` fires as cells near the end appear,
/// so the owner can page in more.
struct ProductGalleryView: View {

    // MARK: - Properties

    let posts: [Post]
    let onReachEnd: (Post) -> Void

    // MARK: - UI

    var body: some View {
        let columns = posts.splitIntoTwo()
        HStack(alignment: .top, spacing: 20) {
            column(columns.left)
            column(columns.right)
        }
        .padding(.horizontal, Constants.Spacing.horizontalPadding)
        .padding(.bottom, Constants.Spacing.horizontalPadding)
    }

    private func column(_ items: [Post]) -> some View {
        LazyVStack(spacing: 10) {
            ForEach(items) { post in
                NavigationLink(value: Route.productDetail(post)) {
                    ProductCardView(post: post)
                }
                .buttonStyle(.plain)
                .onAppear { onReachEnd(post) }
            }
        }
    }
}
