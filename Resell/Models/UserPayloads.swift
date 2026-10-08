//
//  UserPayloads.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation

/// Wrapper for endpoints that return a single user (e.g. `GET /auth/`).
struct UserResponse: Codable {
    let user: User
}

/// Payload for `POST /user/create`.
struct CreateUserBody: Codable {
    let username: String
    let netid: String
    let givenName: String
    let familyName: String
    let photoUrl: String
    let venmoHandle: String
    let email: String
    let googleId: String
    let bio: String
    let fcmToken: String
}

extension CreateUserBody {
    /// Builds the account-creation payload, carrying the immutable Google identity forward.
    init(user: User, username: String, bio: String, venmoHandle: String, imageUrl: String, fcmToken: String) {
        self.init(
            username: username,
            netid: user.netid,
            givenName: user.givenName,
            familyName: user.familyName,
            photoUrl: imageUrl,
            venmoHandle: venmoHandle,
            email: user.email,
            googleId: user.googleId,
            bio: bio,
            fcmToken: fcmToken
        )
    }
}

/// Payload for `POST /auth`, registering the session's push token.
struct AuthorizeBody: Codable {
    let token: String?
}

/// Response for `POST /auth/logout/`.
struct LogoutResponse: Codable {
    let logoutSuccess: Bool
}
