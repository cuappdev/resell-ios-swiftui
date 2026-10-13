//
//  RouteDestinations.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import SwiftUI

extension View {

    /// Registers the app's `Route` → view mapping on the enclosing `NavigationStack`.
    /// Apply once per tab's stack so every push resolves the same way.
    func navigationDestinations() -> some View {
        navigationDestination(for: Route.self) { route in
            switch route {
            case .productDetail(let post):
                ProductDetailView(post: post)
            case .category(let name):
                CategoryView(category: name)
            }
        }
    }
}
