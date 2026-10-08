//
//  NetworkManager.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation
import OSLog

/// The single entry point for backend access. Requests route through `perform`, which injects
/// the bearer token and, on a `401`, refreshes auth once before retrying.
final class NetworkManager: APIClient {

    // MARK: - Singleton

    static let shared = NetworkManager()

    private init() {}

    // MARK: - Properties

    let logger = Logger.services

    #if DEBUG
    private let hostURL = Keys.devServerURL
    #else
    private let hostURL = Keys.prodServerURL
    #endif

    private let maxAttempts = 2

    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    // MARK: - Request Templates

    func get<T: Decodable>(url: URL) async throws -> T {
        let (data, _) = try await perform { try await self.makeRequest(url: url, method: "GET") }
        return try jsonDecoder.decode(T.self, from: data)
    }

    func post<T: Decodable, U: Encodable>(url: URL, body: U) async throws -> T {
        let requestData = try jsonEncoder.encode(body)
        let (data, _) = try await perform { try await self.makeRequest(url: url, method: "POST", body: requestData) }
        return try jsonDecoder.decode(T.self, from: data)
    }

    func post<U: Encodable>(url: URL, body: U) async throws {
        let requestData = try jsonEncoder.encode(body)
        _ = try await perform { try await self.makeRequest(url: url, method: "POST", body: requestData) }
    }

    func post<T: Decodable>(url: URL) async throws -> T {
        let (data, _) = try await perform { try await self.makeRequest(url: url, method: "POST") }
        return try jsonDecoder.decode(T.self, from: data)
    }

    func delete(url: URL) async throws {
        _ = try await perform { try await self.makeRequest(url: url, method: "DELETE") }
    }

    // MARK: - Auth Endpoints

    func authorize(authorizeBody: AuthorizeBody) async throws -> User? {
        try await post(url: try constructURL(endpoint: "/auth"), body: authorizeBody)
    }

    func getUser() async throws -> UserResponse {
        try await get(url: try constructURL(endpoint: "/auth/"))
    }

    func logout() async throws -> LogoutResponse {
        try await post(url: try constructURL(endpoint: "/auth/logout/"))
    }

    func deleteAccount(userID: String) async throws {
        try await delete(url: try constructURL(endpoint: "/auth/id/\(userID)/"))
    }

    // MARK: - User Endpoints

    func createUser(user: CreateUserBody) async throws {
        try await post(url: try constructURL(endpoint: "/user/create"), body: user)
    }

    // MARK: - Image Endpoints

    func uploadImage(image: ImageBody) async throws -> ImageResponse {
        try await post(url: try constructURL(endpoint: "/image/"), body: image)
    }

    // MARK: - Request Execution

    /// Sends the built request. On a `401`, refreshes the auth token and retries up to `maxAttempts`.
    private func perform(requestBuilder: () async throws -> URLRequest, attempt: Int = 1) async throws -> (Data, URLResponse) {
        let request = try await requestBuilder()
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            let error = (try? jsonDecoder.decode(ErrorResponse.self, from: data))
                ?? ErrorResponse(error: "Unauthorized", httpCode: 401)

            guard attempt < maxAttempts else {
                GoogleAuthManager.shared.forceLogout(reason: "Max authentication retry attempts exceeded")
                throw ErrorResponse.maxRetriesHit
            }

            do {
                try await GoogleAuthManager.shared.refreshSignInIfNeeded()
                return try await perform(requestBuilder: requestBuilder, attempt: attempt + 1)
            } catch {
                GoogleAuthManager.shared.forceLogout(reason: "Failed to refresh authentication token")
                throw error
            }
        }

        try validate(data: data, response: response)
        return (data, response)
    }

    private func makeRequest(url: URL, method: String, body: Data? = nil) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let accessToken = try await GoogleAuthManager.shared.getValidToken()
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        return request
    }

    private func constructURL(endpoint: String) throws -> URL {
        guard let url = URL(string: "\(hostURL)\(endpoint)") else {
            logger.error("Failed to construct URL for endpoint: \(endpoint)")
            throw URLError(.badURL)
        }
        return url
    }

    private func validate(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? jsonDecoder.decode(ErrorResponse.self, from: data) {
                throw errorResponse
            }
            throw ErrorResponse(
                error: ErrorResponse.fallbackMessage(forHTTPStatus: httpResponse.statusCode),
                httpCode: httpResponse.statusCode
            )
        }
    }
}
