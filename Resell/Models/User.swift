//
//  User.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation

/// A Resell user as returned by the backend. A pure value type with no SDK or networking concerns.
struct User: Codable, Identifiable, Hashable {
    let firebaseUid: String
    var username: String
    let netid: String
    let givenName: String
    let familyName: String
    let admin: Bool
    let isActive: Bool
    let stars: String
    let numReviews: Int
    let soldPosts: Int?
    var photoUrl: URL
    var venmoHandle: String?
    let email: String
    let googleId: String
    var bio: String

    var id: String { firebaseUid }

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.firebaseUid == rhs.firebaseUid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(firebaseUid)
    }

    /// A copy with the profile fields edited during onboarding applied.
    func updatingProfile(username: String, bio: String, venmoHandle: String, photoUrl: URL) -> User {
        var copy = self
        copy.username = username
        copy.bio = bio
        copy.venmoHandle = venmoHandle
        copy.photoUrl = photoUrl
        return copy
    }
}
