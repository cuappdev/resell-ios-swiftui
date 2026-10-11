//
//  HomeViewModel.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import OSLog
import SwiftUI

extension HomeView {

    @MainActor
    @Observable
    final class ViewModel {

        // MARK: - Properties

        var state: LoadState<[Post]> = .loading

        private var page = 1
        private var hasMore = true
        private var isFetchingMore = false

        /// How close to the end of the feed triggers the next page.
        private let prefetchThreshold = 5

        // MARK: - Functions

        /// Initial load — shows the full-screen loading state.
        func load() async {
            state = .loading
            await fetchFirstPage()
        }

        /// Pull-to-refresh — refetches page 1 without flashing the loading state.
        func refresh() async {
            await fetchFirstPage()
        }

        /// Loads the next page once `post` is within `prefetchThreshold` of the end.
        func loadMoreIfNeeded(currentItem post: Post) async {
            guard case .loaded(let posts) = state, hasMore, !isFetchingMore,
                  let index = posts.firstIndex(of: post),
                  index >= posts.count - prefetchThreshold else {
                return
            }

            isFetchingMore = true
            defer { isFetchingMore = false }
            page += 1

            do {
                let newPosts = Post.sortedByDate(try await NetworkManager.shared.getAllPosts(page: page).posts)
                if newPosts.isEmpty {
                    hasMore = false
                } else {
                    state = .loaded(posts + newPosts)
                }
            } catch {
                page -= 1
                Logger.services.error("Error in HomeView.ViewModel.loadMoreIfNeeded: \(error)")
            }
        }

        // MARK: - Private

        private func fetchFirstPage() async {
            page = 1
            hasMore = true

            do {
                let posts = Post.sortedByDate(try await NetworkManager.shared.getAllPosts().posts)
                state = posts.isEmpty ? .empty : .loaded(posts)
            } catch {
                state = .error((error as? ErrorResponse)?.error ?? "Couldn't load listings.")
                Logger.services.error("Error in HomeView.ViewModel.fetchFirstPage: \(error)")
            }
        }
    }
}
