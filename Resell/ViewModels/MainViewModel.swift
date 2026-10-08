//
//  MainViewModel.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Combine
import OSLog
import SwiftUI

extension MainView {

    /// App-wide session state and the onboarding draft shared across onboarding screens.
    @MainActor
    final class ViewModel: ObservableObject {

        // MARK: - Session State

        /// Drives which top-level screen `ResellApp` shows.
        enum SessionState {
            case restoring
            case signedOut
            case creatingProfile
            case linkingVenmo
            case signedIn
        }

        @Published var sessionState: SessionState = .restoring

        // MARK: - Onboarding Draft

        @Published var username: String = ""
        @Published var bio: String = ""
        @Published var venmoHandle: String = ""
        @Published var profileImage: UIImage?

        // MARK: - Session

        /// Maps a restore result onto the screen the user should land on.
        func apply(_ result: SessionRestoreResult) {
            switch result {
            case .success:
                sessionState = .signedIn
            case .needsProfileCreation:
                sessionState = .creatingProfile
            case .needsSignIn:
                sessionState = .signedOut
            case .error(let message):
                Logger.services.critical("Session restore error: \(message)")
                sessionState = .signedOut
            }
        }

        func logout() {
            UserSessionManager.shared.logout()
            resetOnboardingDraft()
            sessionState = .signedOut
        }

        /// Clears draft data that must not survive across onboarding attempts.
        func resetOnboardingDraft() {
            username = ""
            bio = ""
            venmoHandle = ""
            profileImage = nil
        }
    }
}
