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

        // MARK: - Functions

        /// Signs in with Google, authorizes with the backend, and advances the session:
        /// existing users go straight in, new users move to profile creation.
        func signIn(main: MainView.ViewModel) {
            Task {
                isLoading = true
                defer { isLoading = false }

                do {
                    try await GoogleAuthManager.shared.signIn()
                    main.sessionState = .signedIn
                } catch let error as ErrorResponse where error == .accountCreationNeeded {
                    main.sessionState = .creatingProfile
                } catch {
                    errorText = (error as? ErrorResponse)?.error ?? "An unknown error occurred."
                    didPresentError = true
                    Logger.services.log("Error in LoginView.ViewModel.signIn: \(error)")
                }
            }
        }
    }
}
