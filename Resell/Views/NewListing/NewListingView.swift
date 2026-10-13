//
//  NewListingView.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import PhotosUI
import SwiftUI

struct NewListingView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ViewModel()

    // MARK: - UI

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                imagesSection

                LabeledTextField(label: "Title", placeholder: "What are you selling?", text: $viewModel.title)

                LabeledTextField(
                    label: "Description",
                    maxCharacters: 1000,
                    frameHeight: Constants.Listing.descriptionHeight,
                    isMultiLine: true,
                    placeholder: "Describe your item",
                    text: $viewModel.listingDescription
                )

                LabeledTextField(
                    label: "Price",
                    placeholder: "0.00",
                    keyboardType: .decimalPad,
                    text: $viewModel.price
                )

                chipSection(title: "Category", options: Constants.Listing.categories, selection: $viewModel.category)
                chipSection(title: "Condition", options: Constants.Listing.conditions, selection: $viewModel.condition)

                submitButton
            }
            .padding(Constants.Spacing.horizontalPadding)
        }
        .background(Constants.Colors.white)
        .navigationTitle("New Listing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(Constants.Colors.resellPurple)
            }
        }
        .onChange(of: viewModel.selectedItems) { Task { await viewModel.loadImages() } }
        .onChange(of: viewModel.didPost) {
            if viewModel.didPost { dismiss() }
        }
        .errorAlert($viewModel.errorMessage)
        .endEditingOnTap()
    }

    // MARK: - Photos

    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Photos")
                .font(Constants.Fonts.title1)
                .foregroundStyle(Constants.Colors.black)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                        thumbnail(image, at: index)
                    }

                    if viewModel.remainingImageSlots > 0 {
                        addPhotoButton
                    }
                }
            }
        }
    }

    private func thumbnail(_ image: UIImage, at index: Int) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: Constants.Listing.thumbnailSize, height: Constants.Listing.thumbnailSize)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .topTrailing) {
                Button {
                    viewModel.removeImage(at: index)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Constants.Colors.white, Constants.Colors.black.opacity(0.6))
                        .padding(4)
                }
            }
    }

    private var addPhotoButton: some View {
        PhotosPicker(
            selection: $viewModel.selectedItems,
            maxSelectionCount: viewModel.remainingImageSlots,
            matching: .images
        ) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Constants.Colors.stroke, style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(width: Constants.Listing.thumbnailSize, height: Constants.Listing.thumbnailSize)
                .overlay {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(Constants.Colors.secondaryGray)
                }
        }
    }

    // MARK: - Chips

    private func chipSection(title: String, options: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Constants.Fonts.title1)
                .foregroundStyle(Constants.Colors.black)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        chip(option, isSelected: selection.wrappedValue == option) {
                            selection.wrappedValue = option
                        }
                    }
                }
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

    // MARK: - Submit

    private var submitButton: some View {
        PurpleButton(
            isLoading: viewModel.isLoading,
            isActive: viewModel.isValid,
            text: "Post Listing"
        ) {
            viewModel.createListing()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

#Preview {
    NavigationStack {
        NewListingView()
    }
}
