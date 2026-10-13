//
//  FilterView.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import SwiftUI

/// The Recent Listings filter sheet. Edits a local selection, then applies it to the
/// home feed via the passed-in `HomeView.ViewModel`.
struct FilterView: View {

    // MARK: - Properties

    let homeViewModel: HomeView.ViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var categories: Set<String> = []
    @State private var conditions: Set<String> = []
    @State private var minPrice = ""
    @State private var maxPrice = ""

    // MARK: - UI

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    multiSection("Category", options: Constants.Listing.categories, selected: $categories)
                    multiSection("Condition", options: Constants.Listing.conditions, selected: $conditions)
                    priceSection
                }
                .padding(Constants.Spacing.horizontalPadding)
            }
            .background(Constants.Colors.white)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") { reset() }
                        .foregroundStyle(Constants.Colors.resellPurple)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Constants.Colors.black)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                PurpleButton(text: "Apply") { apply() }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Constants.Spacing.horizontalPadding)
                    .padding(.vertical, 12)
                    .background(Constants.Colors.white)
            }
            .endEditingOnTap()
        }
    }

    private func multiSection(_ title: String, options: [String], selected: Binding<Set<String>>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Constants.Fonts.title1)
                .foregroundStyle(Constants.Colors.black)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        chip(option, isSelected: selected.wrappedValue.contains(option)) {
                            if selected.wrappedValue.contains(option) {
                                selected.wrappedValue.remove(option)
                            } else {
                                selected.wrappedValue.insert(option)
                            }
                        }
                    }
                }
            }
        }
    }

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Price")
                .font(Constants.Fonts.title1)
                .foregroundStyle(Constants.Colors.black)

            HStack(spacing: 12) {
                LabeledTextField(label: "Min", placeholder: "0", keyboardType: .numberPad, text: $minPrice)
                LabeledTextField(label: "Max", placeholder: "Any", keyboardType: .numberPad, text: $maxPrice)
            }
        }
    }

    private func chip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Constants.Fonts.title3)
                .foregroundStyle(isSelected ? Constants.Colors.white : Constants.Colors.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Constants.Colors.resellPurple : Constants.Colors.wash)
                .clipShape(.capsule)
        }
    }

    // MARK: - Actions

    private func apply() {
        let lower = Int(minPrice)
        let upper = Int(maxPrice)
        let price = (lower != nil || upper != nil)
            ? PriceBody(lowerBound: lower ?? 0, upperBound: upper ?? 1_000_000)
            : nil

        let filters = FilterRequestBody(
            sortField: nil,
            price: price,
            categories: categories.isEmpty ? nil : Array(categories),
            condition: conditions.isEmpty ? nil : Array(conditions)
        )

        Task { await homeViewModel.applyFilter(filters) }
        dismiss()
    }

    private func reset() {
        categories = []
        conditions = []
        minPrice = ""
        maxPrice = ""
        Task { await homeViewModel.clearFilter() }
        dismiss()
    }
}
