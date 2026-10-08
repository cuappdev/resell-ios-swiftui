//
//  UIApplication+Extensions.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import UIKit

extension UIApplication {

    /// Dismisses the keyboard and ends any active text field editing.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
