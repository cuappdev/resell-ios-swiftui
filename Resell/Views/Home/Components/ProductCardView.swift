//
//  ProductCardView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// A single listing card in the home gallery: image, title, category, and price.
struct ProductCardView: View {

    // MARK: - Properties

    let post: Post

    @State private var aspectRatio: CGFloat?

    private let width = (UIScreen.width - 68) / 2
    private static let placeholderAspectRatio: CGFloat = 4.0 / 3.0

    private var imageHeight: CGFloat {
        width * (aspectRatio ?? Self.placeholderAspectRatio)
    }

    // MARK: - UI

    var body: some View {
        VStack(spacing: 0) {
            image
            info
        }
        .frame(width: width)
        .clipShape(.rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Constants.Colors.stroke, lineWidth: 1)
        }
    }

    private var image: some View {
        ZStack {
            CachedImageView(url: post.firstImageURL, aspectRatio: $aspectRatio)
                .frame(width: width, height: imageHeight)
                .clipped()

            if post.isSold {
                soldOverlay
            }
        }
    }

    private var soldOverlay: some View {
        ZStack {
            Rectangle()
                .fill(Constants.Colors.black.opacity(0.5))

            Text("Item Sold")
                .font(Constants.Fonts.title2)
                .foregroundStyle(Constants.Colors.white)
        }
        .frame(width: width, height: imageHeight)
    }

    private var info: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(post.title)
                    .font(Constants.Fonts.title3)
                    .foregroundStyle(post.isSold ? Constants.Colors.secondaryGray : Constants.Colors.black)
                    .lineLimit(1)

                Text(post.detailsLabel)
                    .font(Constants.Fonts.subtitle1)
                    .foregroundStyle(Constants.Colors.secondaryGray)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("$\(post.originalPrice)")
                .font(Constants.Fonts.title3)
                .foregroundStyle(post.isSold ? Constants.Colors.secondaryGray : Constants.Colors.black)
                .lineLimit(1)
        }
        .padding(8)
        .background(Constants.Colors.white)
    }
}
