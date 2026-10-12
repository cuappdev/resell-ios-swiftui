//
//  ProductDetailViewModel.swift
//  Resell
//
//  Created by jiwon jeong on 10/11/26.
//

import OSLog
import SwiftUI

extension ProductDetailView {

    @MainActor
    @Observable
    final class ViewModel {

        // MARK: - Properties

        /// Starts as the post passed from the feed, then refreshed with full details on `load`.
        var post: Post
        var isSaved = false
        var errorMessage: String?

        init(post: Post) {
            self.post = post
        }

        // MARK: - Functions

        /// Refreshes the full post (the feed payload can omit seller info / images) and the saved state.
        func load() async {
            do {
                isSaved = try await NetworkManager.shared.postIsSaved(id: post.id).isSaved
            } catch {
                Logger.services.error("Error in ProductDetailView.ViewModel.load (isSaved): \(error)")
            }

            do {
                if let full = try await NetworkManager.shared.getPostByID(id: post.id).post {
                    post = full
                }
            } catch {
                Logger.services.error("Error in ProductDetailView.ViewModel.load (post): \(error)")
            }
        }

        /// Optimistically flips the saved state, rolling back if the request fails.
        func toggleSaved() {
            let newValue = !isSaved
            isSaved = newValue

            Task {
                do {
                    if newValue {
                        _ = try await NetworkManager.shared.savePostByID(id: post.id)
                    } else {
                        _ = try await NetworkManager.shared.unsavePostByID(id: post.id)
                    }
                } catch {
                    isSaved = !newValue
                    errorMessage = "Couldn't update your saved items."
                    Logger.services.error("Error in ProductDetailView.ViewModel.toggleSaved: \(error)")
                }
            }
        }
    }
}
