//
//  UserPayloads.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation

/// Request body for `POST /user/create`.
struct CreateUserBody: Encodable {
    let username, netid, givenName, familyName, photoUrl: String
    let venmoHandle, email, googleId, bio, fcmToken: String
}

/// Request body for `POST /auth`.
struct AuthorizeBody: Encodable {
    let token: String?
}
