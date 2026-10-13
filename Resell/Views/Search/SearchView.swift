//
//  SearchView.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import SwiftUI

struct SearchView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ViewModel()
    @FocusState private var isFocused: Bool

    // MARK: - UI

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            content
        }
        .background(Constants.Colors.white)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { isFocused = true }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Constants.Colors.black)
            }

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Constants.Colors.secondaryGray)

                TextField("What are you looking for?", text: $viewModel.query)
                    .font(Constants.Fonts.body2)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                    .onSubmit { viewModel.submit() }

                if !viewModel.query.isEmpty {
                    Button {
                        viewModel.clearQuery()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Constants.Colors.secondaryGray)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Constants.Colors.wash)
            .clipShape(.capsule)
        }
        .padding(.horizontal, Constants.Spacing.horizontalPadding)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var content: some View {
        if let results = viewModel.results {
            switch results {
            case .loading:
                CustomProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .empty:
                message("No results found.")
            case .error(let text):
                message(text)
            case .loaded(let posts):
                ScrollView {
                    ProductGalleryView(posts: posts) { _ in }
                        .padding(.top, 12)
                }
            }
        } else {
            recentSearches
        }
    }

    @ViewBuilder
    private var recentSearches: some View {
        if viewModel.recentSearches.isEmpty {
            Spacer()
        } else {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Recent")
                        .font(Constants.Fonts.title1)
                        .foregroundStyle(Constants.Colors.black)

                    Spacer()

                    Button("Clear") { viewModel.clearHistory() }
                        .font(Constants.Fonts.title4)
                        .foregroundStyle(Constants.Colors.resellPurple)
                }
                .padding(.bottom, 8)

                ForEach(viewModel.recentSearches, id: \.self) { term in
                    recentRow(term)
                }

                Spacer()
            }
            .padding(.horizontal, Constants.Spacing.horizontalPadding)
            .padding(.top, 8)
        }
    }

    private func recentRow(_ term: String) -> some View {
        Button {
            viewModel.useRecent(term)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .foregroundStyle(Constants.Colors.secondaryGray)
                Text(term)
                    .font(Constants.Fonts.body2)
                    .foregroundStyle(Constants.Colors.black)
                Spacer()
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
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
        SearchView()
    }
}
