//
//  String+Extensions.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation

extension String {

    /// Removes leading and trailing whitespace and collapses runs of whitespace into single spaces.
    func cleaned() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
