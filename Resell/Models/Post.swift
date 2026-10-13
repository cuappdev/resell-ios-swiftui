//
//  Post.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation

/// A marketplace listing.
struct Post: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let categories: [PostCategory]?
    let category: String?
    let condition: String?
    let originalPrice: String
    let images: [String]
    let created: String
    let location: String?
    let sold: Bool?
    let user: User?

    var isSold: Bool { sold == true }

    var firstImageURL: URL? {
        guard let first = images.first else { return nil }
        return URL(string: first)
    }

    /// Category chip text, preferring the structured category then the legacy string.
    var displayCategory: String {
        if let name = categories?.first?.name, !name.isEmpty { return name }
        if let category, !category.isEmpty { return category }
        return "Other"
    }

    /// "Category • Condition" when a condition is present, else just the category.
    var detailsLabel: String {
        guard let condition, !condition.isEmpty else { return displayCategory }
        return "\(displayCategory) • \(condition)"
    }

    static func == (lhs: Post, rhs: Post) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    /// Newest first by `created` timestamp.
    static func sortedByDate(_ posts: [Post]) -> [Post] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return posts.sorted {
            guard let a = formatter.date(from: $0.created),
                  let b = formatter.date(from: $1.created) else { return false }
            return a > b
        }
    }
}

struct PostCategory: Codable, Hashable {
    let id: String
    let name: String
}

struct PostsResponse: Codable {
    let posts: [Post]
}

struct PostResponse: Codable {
    let post: Post?
}

struct SavedResponse: Codable {
    let isSaved: Bool
}

/// Request body for creating a listing (`POST /post/`).
struct PostBody: Encodable {
    let title: String
    let description: String
    let categories: [String]
    let condition: String
    let originalPrice: Double
    let imagesBase64: [String]
    let userId: String
}

struct ListingResponse: Codable {
    let post: Post?
}
