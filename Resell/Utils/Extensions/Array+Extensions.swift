//
//  Array+Extensions.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation

extension Array {

    /// Splits the array into two interleaved columns (even indices, odd indices) for a
    /// two-column staggered gallery.
    func splitIntoTwo() -> (left: [Element], right: [Element]) {
        var left: [Element] = []
        var right: [Element] = []
        for (index, element) in enumerated() {
            if index.isMultiple(of: 2) {
                left.append(element)
            } else {
                right.append(element)
            }
        }
        return (left, right)
    }
}
