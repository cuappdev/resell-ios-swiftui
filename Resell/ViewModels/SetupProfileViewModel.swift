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

        /// Loads, downsizes, and stores the picked photo as the onboarding draft's profile image.
        /// Ignores a stale result if the user picks another photo before this load finishes.
        func loadSelectedImage(into main: MainView.ViewModel) {
            let item = selectedItem
            Task {
                guard let item,
                      let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data),
                      item == selectedItem else {
                    return
                }
                main.profileImage = image.resizedToMaxDimension(512)
            }
        }

        /// The profile is ready to submit once the required fields and the EULA are satisfied.
        func isInputValid(username: String, bio: String, hasImage: Bool) -> Bool {
            !username.cleaned().isEmpty && !bio.cleaned().isEmpty && hasImage && didAgreeWithEULA
        }
    }
}
