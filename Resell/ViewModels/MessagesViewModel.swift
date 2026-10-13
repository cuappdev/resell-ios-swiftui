//
//  MessagesViewModel.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import SwiftUI

extension MessagesView {

    @MainActor
    @Observable
    final class ViewModel {

        enum Tab: String, CaseIterable, Identifiable {
            case purchases = "Purchases"
            case offers = "Offers"
            case archived = "Archived"

            var id: String { rawValue }
        }

        var selectedTab: Tab = .purchases
    }
}
