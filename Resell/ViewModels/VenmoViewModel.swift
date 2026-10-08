//
//  VenmoViewModel.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Combine
import OSLog
import SwiftUI

extension VenmoView {

    @MainActor
    final class ViewModel: ObservableObject {

        // MARK: - Properties

        @Published var isLoading = false
        @Published var didPresentError = false
        @Published var errorText = ""

        // MARK: - Functions

        /// Uploads the profile image and creates the backend account, finishing onboarding.
        func createUser(username: String, bio: String, venmoHandle: String, image: UIImage?) async -> Bool {
            guard let image else {
                presentError("Please select a profile picture.")
                return false
            }
            guard let imageBase64 = image.resizedToMaxDimension(256).toBase64() else {
                presentError("Failed to process profile image. Please try again.")
                return false
            }
            guard let googleUser = GoogleAuthManager.shared.user else {
                presentError("Authentication failed. Please try logging in again.")
                return false
            }

            isLoading = true
            defer { isLoading = false }

            do {
                let imageUrl = try await NetworkManager.shared.uploadImage(
                    image: ImageBody(imageBase64: imageBase64)
                ).image

                let body = CreateUserBody(
                    user: googleUser,
                    username: username,
                    bio: bio,
                    venmoHandle: venmoHandle,
                    imageUrl: imageUrl,
                    fcmToken: ""
                )
                try await NetworkManager.shared.createUser(user: body)

                let photoUrl = URL(string: imageUrl) ?? googleUser.photoUrl
                GoogleAuthManager.shared.user = googleUser.updatingProfile(
                    username: username,
                    bio: bio,
                    venmoHandle: venmoHandle,
                    photoUrl: photoUrl
                )
                return true
            } catch {
                if error as? ErrorResponse == .usernameAlreadyExists {
                    presentError("That username is already taken.")
                } else {
                    presentError((error as? ErrorResponse)?.error ?? "Something went wrong. Please try again.")
                }
                Logger.services.error("Error in VenmoView.ViewModel.createUser: \(error)")
                return false
            }
        }

        // MARK: - Private

        private func presentError(_ message: String) {
            errorText = message
            didPresentError = true
        }
    }
}
