//
//  KeychainManager.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation
import Security

/// Stores small sensitive values (tokens, identifiers) in the system Keychain.
final class KeychainManager {

    // MARK: - Singleton

    static let shared = KeychainManager()

    private init() {}

    // MARK: - Functions

    func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }

        let deleteQuery = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary
        SecItemDelete(deleteQuery)

        let addQuery = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ] as CFDictionary
        SecItemAdd(addQuery, nil)
    }

    func get(forKey key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var result: AnyObject?
        guard SecItemCopyMatching(query, &result) == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func delete(forKey key: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary
        SecItemDelete(query)
    }
}
