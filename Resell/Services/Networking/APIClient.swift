//
//  APIClient.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation

/// The generic request surface every networking call is built on.
protocol APIClient {
    func get<T: Decodable>(url: URL) async throws -> T
    func post<T: Decodable, U: Encodable>(url: URL, body: U) async throws -> T
    func post<U: Encodable>(url: URL, body: U) async throws
    func delete(url: URL) async throws
}
