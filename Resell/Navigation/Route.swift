//
//  Route.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation

/// In-app navigation destinations, pushed onto a tab's `NavigationStack` via
/// `.navigationDestination(for: Route.self)`.
enum Route: Hashable {
    case productDetail(Post)
    case category(String)
}
