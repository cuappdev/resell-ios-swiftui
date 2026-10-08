//
//  Keys.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import Foundation

/// Backend URLs, client IDs, and secrets. Never hardcode these at a call site.
enum Keys {
    static let devServerURL = mainInfoValue(for: "RESELL_DEV_URL")
    static let prodServerURL = mainInfoValue(for: "RESELL_PROD_URL")

    static let googleClientID = googleServiceInfo["CLIENT_ID"] as? String ?? ""

    private static let googleServiceInfo: NSDictionary = {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) else { return [:] }
        return dict
    }()

    private static func mainInfoValue(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) else { return "" }
        return dict[key] as? String ?? ""
    }
}
