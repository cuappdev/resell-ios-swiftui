//
//  Filter.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import Foundation

/// Request body for the unified filter endpoint (`POST /post/filter/`).
struct FilterRequestBody: Encodable {
    var sortField: String?
    var price: PriceBody?
    var categories: [String]?
    var condition: [String]?
}

struct PriceBody: Encodable {
    let lowerBound: Int
    let upperBound: Int
}
