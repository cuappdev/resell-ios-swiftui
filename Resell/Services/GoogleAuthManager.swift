//
//  GoogleAuthManager.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import FirebaseAuth
import GoogleSignIn
import OSLog
import UIKit

/// Owns Google + Firebase authentication and exchanges credentials for a backend session.
final class GoogleAuthManager {

    // MARK: - Singleton

    static let shared = GoogleAuthManager()

    private init() {}

    // MARK: - Properties

    let logger = Logger.services

    /// The authenticated user, populated by the backend `authorize` call.
    var user: User?

    // MARK: - Token

    /// Returns a valid Firebase ID token, used as the backend bearer token. Firebase caches internally.
    func getValidToken() async throws -> String {
        guard let token = try await Auth.auth().currentUser?.getIDToken(forcingRefresh: false) else {
            throw GoogleAuthError.noUserSignedIn
        }
        return token
    }

    // MARK: - Sign In

    func signIn() async throws {
        guard let presenting = await rootViewController() else {
            throw GoogleAuthError.noUserSignedIn
        }

        let result: GIDSignInResult
        do {
            result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        } catch let error as NSError where error.code == GIDSignInError.canceled.rawValue {
            throw GoogleAuthError.cancelled
        }

        try await exchangeCredentials(for: result.user)
        try await authorizeUser()
    }

    /// Refreshes the current (or restored) Google session. Throwing means a full logout is required.
    func refreshSignInIfNeeded() async throws {
        if GIDSignIn.sharedInstance.currentUser == nil {
            try await GIDSignIn.sharedInstance.restorePreviousSignIn()
        }

        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            throw GoogleAuthError.noUserSignedIn
        }

        try await currentUser.refreshTokensIfNeeded()
        try await exchangeCredentials(for: currentUser)
        try await authorizeUser()
    }

    // MARK: - Sign Out

    func signOut() {
        logger.info("Signing out user")
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
        } catch {
            logger.error("Error signing out from Firebase: \(error.localizedDescription)")
        }
        user = nil
    }

    /// Signs out and broadcasts a logout when authentication can't be recovered.
    func forceLogout(reason: String = "Authentication failed") {
        logger.warning("Forcing user logout. Reason: \(reason)")
        signOut()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Constants.Notifications.logoutUser, object: nil)
        }
    }

    // MARK: - Private

    /// Exchanges the Google ID token for a Firebase session and stores a draft `User`.
    private func exchangeCredentials(for googleUser: GIDGoogleUser) async throws {
        guard let idToken = googleUser.idToken?.tokenString else {
            throw GoogleAuthError.noUserSignedIn
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: googleUser.accessToken.tokenString
        )
        let authResult = try await Auth.auth().signIn(with: credential)
        user = draftUser(from: googleUser, firebaseUid: authResult.user.uid)
    }

    /// Derives a draft `User` from a freshly signed-in Google account.
    private func draftUser(from googleUser: GIDGoogleUser, firebaseUid: String) -> User {
        let email = googleUser.profile?.email ?? ""
        let netid = email.split(separator: "@").first.map(String.init) ?? ""
        let defaultImageUrl = URL(string: "http://www.gravatar.com/avatar/?d=mp")!

        return User(
            firebaseUid: firebaseUid,
            username: email,
            netid: netid,
            givenName: googleUser.profile?.givenName ?? "",
            familyName: googleUser.profile?.familyName ?? "",
            admin: false,
            isActive: true,
            stars: "0.0",
            numReviews: 0,
            soldPosts: 0,
            photoUrl: googleUser.profile?.imageURL(withDimension: 512) ?? defaultImageUrl,
            venmoHandle: "",
            email: email,
            googleId: googleUser.userID ?? "",
            bio: ""
        )
    }

    /// Registers the session with the backend. Throws `ErrorResponse.accountCreationNeeded` for new users.
    private func authorizeUser() async throws {
        let body = AuthorizeBody(token: "")
        user = try await NetworkManager.shared.authorize(authorizeBody: body)
    }

    @MainActor
    private func rootViewController() -> UIViewController? {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?.rootViewController
    }
}

enum GoogleAuthError: Error, LocalizedError {
    case noUserSignedIn
    case cancelled

    var errorDescription: String? {
        switch self {
        case .noUserSignedIn: return "No user is currently signed in."
        case .cancelled: return "Sign-in was cancelled."
        }
    }
}
