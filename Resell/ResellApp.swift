//
//  ResellApp.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import FirebaseCore
import GoogleSignIn
import SwiftUI

@main
struct ResellApp: App {

    // MARK: - Properties

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var mainViewModel = MainView.ViewModel()

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                content
                    .animation(
                        .easeInOut(duration: Constants.SessionLoading.fadeDuration),
                        value: mainViewModel.sessionState
                    )
                    .environmentObject(mainViewModel)
                    .onOpenURL { GIDSignIn.sharedInstance.handle($0) }
            }
            .task { await restoreSession() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch mainViewModel.sessionState {
        case .restoring:
            SessionLoadingView()
        case .signedOut:
            LoginView()
        case .creatingProfile:
            SetupProfileView()
        case .linkingVenmo:
            VenmoView()
        case .signedIn:
            MainView()
        }
    }

    // MARK: - Session Restore

    /// Restores the previous session, holding the splash for a minimum so the transition isn't jarring.
    private func restoreSession() async {
        let start = Date()
        let result = await UserSessionManager.shared.restorePreviousSession()

        let elapsed = Date().timeIntervalSince(start)
        let remaining = Constants.SessionLoading.minimumDuration - elapsed
        if remaining > 0 {
            try? await Task.sleep(for: .seconds(remaining))
        }

        await MainActor.run { mainViewModel.apply(result) }
    }
}

// MARK: - AppDelegate

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
