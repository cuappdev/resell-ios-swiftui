//
//  LoadState.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation

/// The loading lifecycle of a content screen. Views switch on this instead of juggling bools.
enum LoadState<Value> {
    case loading
    case loaded(Value)
    case empty
    case error(String)
}
