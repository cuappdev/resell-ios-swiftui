//
//  Post+Mock.swift
//  Resell
//
//  Created by jiwon jeong on 10/11/26.
//

#if DEBUG
import Foundation

extension User {
    static let mock = User(
        firebaseUid: "mock-user",
        username: "janedoe",
        netid: "jd123",
        givenName: "Jane",
        familyName: "Doe",
        admin: false,
        isActive: true,
        stars: "4.8",
        numReviews: 12,
        soldPosts: 3,
        photoUrl: URL(string: "https://picsum.photos/id/64/200")!,
        venmoHandle: "jane-doe",
        email: "jd123@cornell.edu",
        googleId: "google-1",
        bio: "Selling things I no longer need."
    )
}

extension Post {
    static let mock = Post(
        id: "mock-post",
        title: "Vintage Denim Jacket",
        description: "Lightly worn, size M. Great condition, no stains or tears.",
        categories: [PostCategory(id: "1", name: "Clothing")],
        category: "Clothing",
        condition: "Gently Used",
        originalPrice: "45",
        images: ["https://picsum.photos/id/1011/400/600", "https://picsum.photos/id/1012/400/500"],
        created: "2026-10-01T12:00:00.000Z",
        location: "North Campus",
        sold: false,
        user: .mock
    )

    static let mocks: [Post] = (0..<6).map { index in
        Post(
            id: "mock-\(index)",
            title: "Listing \(index)",
            description: "A sample listing.",
            categories: [PostCategory(id: "1", name: "Books")],
            category: "Books",
            condition: index.isMultiple(of: 2) ? "Never Used" : "Gently Used",
            originalPrice: "\(10 + index * 5)",
            images: ["https://picsum.photos/id/\(20 + index)/400/\(400 + index * 40)"],
            created: "2026-10-0\(index + 1)T12:00:00.000Z",
            location: nil,
            sold: index == 2,
            user: .mock
        )
    }
}
#endif
