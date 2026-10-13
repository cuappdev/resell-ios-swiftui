//
//  CategoryView.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import SwiftUI

struct CategoryView: View {

    // MARK: - Properties

    let category: String

    @State private var viewModel = ViewModel()

    // MARK: - UI

    var body: some View {
        content
            .background(Constants.Colors.white)
            .navigationTitle(category)
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load(category) }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            CustomProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            message("No \(category.lowercased()) listings yet.")
        case .error(let text):
            message(text)
        case .loaded(let posts):
            ScrollView {
                ProductGalleryView(posts: posts) { _ in }
                    .padding(.top, 12)
            }
        }
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .font(Constants.Fonts.body1)
            .foregroundStyle(Constants.Colors.secondaryGray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
