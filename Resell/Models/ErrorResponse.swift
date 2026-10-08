//
//  ErrorResponse.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation

/// A typed error decoded from the backend, carrying the server message and HTTP status.
struct ErrorResponse: Codable, Error, Equatable, LocalizedError {
    let error: String
    let httpCode: Int

    static let accountCreationNeeded = ErrorResponse(error: "User not found. Please create an account first.", httpCode: 403)
    static let usernameAlreadyExists = ErrorResponse(error: "UserModel with same username already exists!", httpCode: 409)
    static let userNotFound = ErrorResponse(error: "User not found.", httpCode: 404)
    static let maxRetriesHit = ErrorResponse(error: "Max retries hit. Please try again later.", httpCode: 429)

    var errorDescription: String? { error }

    /// Short, actionable copy when the response body isn't standard JSON.
    static func fallbackMessage(forHTTPStatus code: Int) -> String {
        switch code {
        case 401: return "Your session expired. Sign in again, then try once more."
        case 403: return "You don't have permission to do that."
        case 404: return "That wasn't found. It may have been removed or the link is outdated."
        case 409: return "That conflicts with what's already saved."
        case 429: return "Too many requests. Wait a few seconds and try again."
        case 500...599: return "Something went wrong on the server. Try again in a few minutes."
        default: return "Something went wrong (HTTP \(code))."
        }
    }
}
