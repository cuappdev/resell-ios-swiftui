//
//  UIScreen+Extensions.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import UIKit

extension UIScreen {

    /// Bounds of the active window scene's screen.
    private static var currentBounds: CGRect {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds ?? .zero
    }

    static var width: CGFloat { currentBounds.width }
    static var height: CGFloat { currentBounds.height }
}
