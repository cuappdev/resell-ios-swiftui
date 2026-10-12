//
//  ProfileViewModel.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import OSLog
import SwiftUI

extension ProfileView {

    @MainActor
    @Observable
    final class ViewModel {

        // MARK: - Tab

        enum Tab: String, CaseIterable, Identifiable {
            case listings = "Listings"
            case saved = "Saved"
            case archive = "Archive"

            var id: String { rawValue }
        }

        // MARK: - Properties

        var selectedTab: Tab = .listings
        var state: LoadState<[Post]> = .loading

        /// The signed-in user, from the auth layer — no extra fetch needed for the header.
        var user: User? { GoogleAuthManager.shared.user }

        private var cache: [Tab: [Post]] = [:]

        // MARK: - Functions

        /// Loads a tab, serving a cached result if one exists.
        func load(_ tab: Tab) async {
            if let cached = cache[tab] {
                state = cached.isEmpty ? .empty : .loaded(cached)
                return
            }
            state = .loading
            await fetch(tab)
        }

        /// Pull-to-refresh — drops the cache and refetches.
        func refresh(_ tab: Tab) async {
            cache[tab] = nil
            await fetch(tab)
        }

        // MARK: - Private

        private func fetch(_ tab: Tab) async {
            do {
                let posts = Post.sortedByDate(try await posts(for: tab))
                cache[tab] = posts
                state = posts.isEmpty ? .empty : .loaded(posts)
            } catch {
                state = .error((error as? ErrorResponse)?.error ?? "Couldn't load these posts.")
                Logger.services.error("Error in ProfileView.ViewModel.fetch(\(tab.rawValue)): \(error)")
            }
        }

        private func posts(for tab: Tab) async throws -> [Post] {
            switch tab {
            case .listings:
                guard let id = user?.firebaseUid else { return [] }
                return try await NetworkManager.shared.getPostsByUserID(id: id).posts
            case .saved:
                return try await NetworkManager.shared.getSavedPosts().posts
            case .archive:
                guard let id = user?.firebaseUid else { return [] }
                return try await NetworkManager.shared.getArchivedPostsByUserID(id: id).posts
            }
        }
    }
}
