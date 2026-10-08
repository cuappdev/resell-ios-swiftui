//
//  LoginViewModel.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Combine
import OSLog
import SwiftUI

extension LoginView {

    @MainActor
    final class ViewModel: ObservableObject {

        // MARK: - Properties

        @Published var isLoading = false
        @Published var didPresentError = false
        @Published var errorText = ""

        // MARK: - Result

        enum LoginResult {
            case success
            case accountCreationNeeded
            case failed
        }

        // MARK: - Functions

        /// Signs in with Google and authorizes with the backend, distinguishing new users
        /// (who still need a profile) from an outright failure.
        func googleSignIn() async -> LoginResult {
            isLoading = true
            defer { isLoading = false }

            do {
                try await GoogleAuthManager.shared.signIn()
                return .success
            } catch let error as ErrorResponse where error == .accountCreationNeeded {
                return .accountCreationNeeded
            } catch {
                errorText = (error as? ErrorResponse)?.error ?? "An unknown error occurred."
                didPresentError = true
                Logger.services.log("Error in LoginView.ViewModel.googleSignIn: \(error)")
                return .failed
            }
        }
    }
}
