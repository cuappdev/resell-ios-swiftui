//
//  Constants.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// Resell's design system and per-screen layout values.
enum Constants {

    // MARK: - Colors

    enum Colors {
        static let black = Color(red: 0 / 255, green: 0 / 255, blue: 0 / 255)
        static let errorRed = Color(red: 242 / 255, green: 0 / 255, blue: 0 / 255)
        static let inactiveGray = Color(red: 190 / 255, green: 190 / 255, blue: 190 / 255)
        static let purpleWash = Color(red: 250 / 255, green: 247 / 255, blue: 255 / 255)
        static let resellPurple = Color(red: 158 / 255, green: 112 / 255, blue: 246 / 255)
        static let secondaryGray = Color(red: 77 / 255, green: 77 / 255, blue: 77 / 255)
        static let stroke = Color(red: 214 / 255, green: 214 / 255, blue: 214 / 255)
        static let wash = Color(red: 244 / 255, green: 244 / 255, blue: 244 / 255)
        static let white = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)

        static let resellGradient = LinearGradient(
            stops: [
                .init(color: Color(red: 173 / 255, green: 104 / 255, blue: 227 / 255), location: 0.0),
                .init(color: Color(red: 222 / 255, green: 108 / 255, blue: 211 / 255), location: 0.5),
                .init(color: Color(red: 223 / 255, green: 152 / 255, blue: 86 / 255), location: 1.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        static let resellBlurGradient = LinearGradient(
            stops: [
                .init(color: Color(red: 255 / 255, green: 19 / 255, blue: 231 / 255), location: 0.0),
                .init(color: Color(red: 255 / 255, green: 122 / 255, blue: 0 / 255), location: 1.0)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }

    // MARK: - Fonts

    enum Fonts {
        static let resellLogo = Font.custom("ReemKufi-Regular", size: 48)

        static let h1 = Font.custom("Rubik-Medium", size: 32)
        static let h2 = Font.custom("Rubik-Medium", size: 22)
        static let h3 = Font.custom("Rubik-Medium", size: 20)

        static let body1 = Font.custom("Rubik-Regular", size: 18)
        static let body2 = Font.custom("Rubik-Regular", size: 16)

        static let title1 = Font.custom("Rubik-Medium", size: 18)
        static let title4 = Font.custom("Rubik-Regular", size: 14)
    }

    // MARK: - Spacing

    enum Spacing {
        static let horizontalPadding: CGFloat = 24.0
    }

    // MARK: - Notifications

    enum Notifications {
        static let logoutUser = Notification.Name("LogoutUser")
    }

    // MARK: - Session Loading

    enum SessionLoading {
        static let logoTopPadding: CGFloat = 180
        static let spinnerSize: CGFloat = 40
        static let fadeDuration: CGFloat = 0.3
        /// Keep the splash up at least this long so the restore flash isn't jarring.
        static let minimumDuration: TimeInterval = 0.8
    }

    // MARK: - Login

    enum Login {
        static let logoTopPadding: CGFloat = 180
        static let buttonHorizontalPadding: CGFloat = 28
        static let appDevBottomPadding: CGFloat = 24
        static let errorSheetHeight: CGFloat = 200
        static let errorTextWidth: CGFloat = 190
        static let errorTextTopPadding: CGFloat = 48
    }

    // MARK: - Setup Profile

    enum SetupProfile {
        static let imageSize: CGFloat = 132
        static let imageVerticalPadding: CGFloat = 40
        static let usernameBottomPadding: CGFloat = 32
        static let bioBottomPadding: CGFloat = 24
        static let bioMaxCharacters: Int = 255
        static let bioHeight: CGFloat = 83
        static let checkboxSize: CGFloat = 24
        static let checkboxInnerSize: CGFloat = 17
        static let checkboxBorderWidth: CGFloat = 2.5
        static let compactScreenWidth: CGFloat = 380
        static let buttonHorizontalPadding: CGFloat = 80
        static let eulaURL = "https://www.cornellappdev.com/license/resell"
    }

    // MARK: - Venmo

    enum Venmo {
        static let captionTopPadding: CGFloat = 24
        static let fieldTopPadding: CGFloat = 46
        static let skipTopPadding: CGFloat = 14
    }
}
