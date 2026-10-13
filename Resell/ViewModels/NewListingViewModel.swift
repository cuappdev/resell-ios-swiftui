//
//  NewListingViewModel.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import OSLog
import PhotosUI
import SwiftUI

extension NewListingView {

    @MainActor
    @Observable
    final class ViewModel {

        // MARK: - Properties

        var selectedImages: [UIImage] = []
        var selectedItems: [PhotosPickerItem] = []

        var title = ""
        var listingDescription = ""
        var price = ""
        var category = Constants.Listing.categories.first ?? "Other"
        var condition = Constants.Listing.conditions.first ?? "Gently Used"

        var isLoading = false
        var errorMessage: String?
        var didPost = false

        var remainingImageSlots: Int {
            max(0, Constants.Listing.maxImages - selectedImages.count)
        }

        var isValid: Bool {
            !title.cleaned().isEmpty
                && !listingDescription.cleaned().isEmpty
                && Double(price) != nil
                && !selectedImages.isEmpty
        }

        // MARK: - Functions

        /// Loads newly picked photos (up to the remaining slots) and clears the picker selection.
        func loadImages() async {
            guard !selectedItems.isEmpty, remainingImageSlots > 0 else {
                selectedItems = []
                return
            }

            var loaded: [UIImage] = []
            for item in selectedItems.prefix(remainingImageSlots) {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    loaded.append(image)
                }
            }

            selectedImages.append(contentsOf: loaded)
            selectedItems = []
        }

        func removeImage(at index: Int) {
            guard selectedImages.indices.contains(index) else { return }
            selectedImages.remove(at: index)
        }

        /// Encodes the photos and creates the listing, broadcasting so the feed can refresh.
        func createListing() {
            guard !isLoading else { return }
            guard let user = GoogleAuthManager.shared.user else {
                errorMessage = "Please sign in again."
                return
            }

            let images = selectedImages
            isLoading = true

            Task {
                defer { isLoading = false }
                do {
                    let body = PostBody(
                        title: title.cleaned(),
                        description: listingDescription.cleaned(),
                        categories: [category],
                        condition: condition,
                        originalPrice: Double(price) ?? 0,
                        imagesBase64: await Self.encode(images),
                        userId: user.firebaseUid
                    )

                    _ = try await NetworkManager.shared.createPost(postBody: body)
                    NotificationCenter.default.post(name: Constants.Notifications.newListingCreated, object: nil)
                    clear()
                    didPost = true
                } catch {
                    errorMessage = (error as? ErrorResponse)?.error ?? "Couldn't post your listing."
                    Logger.services.error("Error in NewListingView.ViewModel.createListing: \(error)")
                }
            }
        }

        func clear() {
            selectedImages = []
            selectedItems = []
            title = ""
            listingDescription = ""
            price = ""
            category = Constants.Listing.categories.first ?? "Other"
            condition = Constants.Listing.conditions.first ?? "Gently Used"
        }

        // MARK: - Private

        /// Downsizes and base64-encodes off the main actor (image work is expensive).
        private nonisolated static func encode(_ images: [UIImage]) async -> [String] {
            images.map { $0.resizedToMaxDimension(512).toBase64() ?? "" }
        }
    }
}
