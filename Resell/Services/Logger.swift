//
//  Logger.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import OSLog

/// Resell's logging categories. Use these instead of `print`.
extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.cornellappdev.Resell"

    /// Decoding, parsing, and model-level issues.
    static let data = Logger(subsystem: subsystem, category: "data")

    /// Network calls, auth, and other platform services.
    static let services = Logger(subsystem: subsystem, category: "services")
}
