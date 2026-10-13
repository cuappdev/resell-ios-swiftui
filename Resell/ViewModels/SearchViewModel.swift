//
//  SearchViewModel.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import OSLog
import SwiftUI

extension SearchView {

    @MainActor
    @Observable
    final class ViewModel {

        // MARK: - Properties

        var query = ""
        /// `nil` while idle (showing recent searches); set once a search runs.
        var results: LoadState<[Post]>?
        private(set) var recentSearches: [String]

        private let defaults = UserDefaults.standard
        private let historyKey = "searchHistory"
        private let maxHistory = 10
        private var searchTask: Task<Void, Never>?

        init() {
            recentSearches = defaults.stringArray(forKey: historyKey) ?? []
        }

        // MARK: - Functions

        func submit() {
            runSearch(query.cleaned())
        }

        func useRecent(_ term: String) {
            query = term
            runSearch(term)
        }

        func clearQuery() {
            query = ""
            results = nil
            searchTask?.cancel()
        }

        func clearHistory() {
            recentSearches = []
            defaults.removeObject(forKey: historyKey)
        }

        // MARK: - Private

        /// Debounced in effect: cancels the previous request before starting the next.
        private func runSearch(_ term: String) {
            guard !term.isEmpty else { return }
            saveToHistory(term)

            searchTask?.cancel()
            results = .loading
            searchTask = Task {
                do {
                    let posts = Post.sortedByDate(try await NetworkManager.shared.getSearchedPosts(keywords: term).posts)
                    guard !Task.isCancelled else { return }
                    results = posts.isEmpty ? .empty : .loaded(posts)
                } catch {
                    guard !Task.isCancelled else { return }
                    results = .error((error as? ErrorResponse)?.error ?? "Search failed. Try again.")
                    Logger.services.error("Error in SearchView.ViewModel.runSearch: \(error)")
                }
            }
        }

        private func saveToHistory(_ term: String) {
            var history = recentSearches.filter { $0.caseInsensitiveCompare(term) != .orderedSame }
            history.insert(term, at: 0)
            if history.count > maxHistory { history = Array(history.prefix(maxHistory)) }
            recentSearches = history
            defaults.set(history, forKey: historyKey)
        }
    }
}
