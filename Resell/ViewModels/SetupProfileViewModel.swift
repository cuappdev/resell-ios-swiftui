//
//  SetupProfileViewModel.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Combine
import PhotosUI
import SwiftUI

extension SetupProfileView {

    @MainActor
    final class ViewModel: ObservableObject {

        // MARK: - Properties

        @Published var didShowPhotosPicker = false
        @Published var didShowWebView = false
        @Published var didAgreeWithEULA = false
        @Published var selectedItem: PhotosPickerItem?

        // MARK: - Functions

        /// Loads and downsizes a picked photo for use as the profile image.
        func loadImage(from item: PhotosPickerItem?) async -> UIImage? {
            guard let item,
                  let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                return nil
            }
            return image.resizedToMaxDimension(512)
        }

        /// The profile is ready to submit once the required fields and the EULA are satisfied.
        func isInputValid(username: String, bio: String, hasImage: Bool) -> Bool {
            !username.cleaned().isEmpty && !bio.cleaned().isEmpty && hasImage && didAgreeWithEULA
        }
    }
}
