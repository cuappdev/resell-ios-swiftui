//
//  UserSessionManager.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Combine
import OSLog
import SwiftUI

/// The outcome of attempting to restore a previous session on launch.
enum SessionRestoreResult {
    case success
    case needsSignIn
    case needsProfileCreation
    case error(String)
}

/// Uplift-style session façade: owns restore and logout, delegating the Google/Firebase and
/// backend-authorize work to `GoogleAuthManager` and `NetworkManager`.
final class UserSessionManager: ObservableObject {

    // MARK: - Singleton

    static let shared = UserSessionManager()

    private init() {}

    // MARK: - Properties

    private let logger = Logger.services

    /// The signed-in user, mirrored from `GoogleAuthManager` for convenience.
    var currentUser: User? { GoogleAuthManager.shared.user }

    // MARK: - Session

    /// Restores the previous Google/Firebase session and re-authorizes it with the backend.
    func restorePreviousSession() async -> SessionRestoreResult {
        do {
            try await GoogleAuthManager.shared.refreshSignInIfNeeded()
            logger.log("Successfully restored session")
            return .success
        } catch {
            return restoreResult(for: error)
        }
    }

    /// Clears Google, Firebase, and backend session state.
    func logout() {
        GoogleAuthManager.shared.signOut()
    }

    // MARK: - Helpers

    /// Classifies a failed restore: a missing account means profile creation, no sign-in means sign-in.
    private func restoreResult(for error: Error) -> SessionRestoreResult {
        if let errorResponse = error as? ErrorResponse, errorResponse == .accountCreationNeeded {
            return .needsProfileCreation
        }
        if case GoogleAuthError.noUserSignedIn = error {
            return .needsSignIn
        }
        logger.log("Session restore failed, requiring sign-in: \(error.localizedDescription)")
        return .needsSignIn
    }
}
