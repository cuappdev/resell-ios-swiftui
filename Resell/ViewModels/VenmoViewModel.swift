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

        /// Finishes onboarding with the entered Venmo handle.
        func submit(main: MainView.ViewModel) {
            createAccount(main: main)
        }

        /// Finishes onboarding without a Venmo handle.
        func skip(main: MainView.ViewModel) {
            main.venmoHandle = ""
            createAccount(main: main)
        }

        // MARK: - Private

        /// Uploads the profile image, creates the backend account, and advances to the signed-in app.
        private func createAccount(main: MainView.ViewModel) {
            guard !isLoading else { return }

            guard let googleUser = GoogleAuthManager.shared.user else {
                presentError("Authentication failed. Please try logging in again.")
                return
            }
            guard let imageBase64 = main.profileImage?.resizedToMaxDimension(256).toBase64() else {
                presentError("Failed to process profile image. Please try again.")
                return
            }

            Task {
                isLoading = true
                defer { isLoading = false }

                do {
                    let imageUrl = try await NetworkManager.shared.uploadImage(
                        image: ImageBody(imageBase64: imageBase64)
                    ).image

                    let body = CreateUserBody(
                        username: main.username,
                        netid: googleUser.netid,
                        givenName: googleUser.givenName,
                        familyName: googleUser.familyName,
                        photoUrl: imageUrl,
                        venmoHandle: main.venmoHandle,
                        email: googleUser.email,
                        googleId: googleUser.googleId,
                        bio: main.bio,
                        fcmToken: ""
                    )
                    try await NetworkManager.shared.createUser(user: body)

                    GoogleAuthManager.shared.user = googleUser.updatingProfile(
                        username: main.username,
                        bio: main.bio,
                        venmoHandle: main.venmoHandle,
                        photoUrl: URL(string: imageUrl) ?? googleUser.photoUrl
                    )

                    main.resetOnboardingDraft()
                    withAnimation { main.sessionState = .signedIn }
                } catch {
                    if error as? ErrorResponse == .usernameAlreadyExists {
                        presentError("That username is already taken.")
                    } else {
                        presentError((error as? ErrorResponse)?.error ?? "Something went wrong. Please try again.")
                    }
                    Logger.services.error("Error in VenmoView.ViewModel.createAccount: \(error)")
                }
            }
        }

        private func presentError(_ message: String) {
            errorText = message
            didPresentError = true
        }
    }
}
