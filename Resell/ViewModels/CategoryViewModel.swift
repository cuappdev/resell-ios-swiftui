//
//  CategoryViewModel.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import OSLog
import SwiftUI

extension CategoryView {

    @MainActor
    @Observable
    final class ViewModel {

        var state: LoadState<[Post]> = .loading

        func load(_ category: String) async {
            state = .loading
            do {
                let posts = Post.sortedByDate(
                    try await NetworkManager.shared.getFilteredPostsByCategory(categories: [category]).posts
                )
                state = posts.isEmpty ? .empty : .loaded(posts)
            } catch {
                state = .error((error as? ErrorResponse)?.error ?? "Couldn't load \(category) listings.")
                Logger.services.error("Error in CategoryView.ViewModel.load: \(error)")
            }
        }
    }
}
