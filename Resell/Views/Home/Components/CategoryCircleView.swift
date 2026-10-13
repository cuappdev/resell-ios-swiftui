//
//  CategoryCircleView.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import SwiftUI

/// A category tile in the home "Shop By Category" row: a colored circle with the category
/// icon and its name beneath.
struct CategoryCircleView: View {

    let name: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Constants.Listing.categoryColor(name))

                Image(name)
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            }
            .frame(width: Constants.Home.categoryCircleSize, height: Constants.Home.categoryCircleSize)

            Text(name)
                .font(Constants.Fonts.title3)
                .foregroundStyle(Constants.Colors.black)
        }
    }
}
