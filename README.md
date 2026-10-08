# Resell iOS (SwiftUI)

A ground-up SwiftUI rewrite of Resell, following a standard MVVM architecture inspired by the
Uplift iOS codebase.

## Architecture

- **No router.** Navigation is driven by a `SessionState` enum on `MainView.ViewModel`;
  `ResellApp` switches on it to show each top-level screen.
- **ViewModels are nested** in an extension of the view they belong to
  (`extension LoginView { @MainActor final class ViewModel: ObservableObject }`), one per screen.
- **Views only draw.** Each `body` is split into small `private var`/`private func` pieces; all
  complex logic lives in the corresponding ViewModel.
- **Design tokens** (colors, fonts, spacing, per-screen layout) live in `Utils/Constants.swift`.
- **Services** (`Services/`) own auth, networking, keychain, and logging. Models are inert
  `Codable` value types.

## Project layout

```
Resell/
  Core/            app entry (ResellApp)
  Models/          Codable value types + wire payloads
  Services/        UserSessionManager, GoogleAuthManager, KeychainManager, Logger
    Networking/    APIClient, NetworkManager
  Utils/           Constants, Keys, Extensions
  ViewModels/      nested `extension XView { ViewModel }` files
  Views/
    Components/    shared, app-wide UI primitives
    Onboarding/    Login / SessionLoading / SetupProfile / Venmo
      Components/  onboarding-only UI (feature-scoped components)
```

## Setup

1. **Packages** (Swift Package Manager, already referenced): `firebase-ios-sdk` (12.x) and
   `GoogleSignIn-iOS` (10.x).
2. **Secrets** — drop your files into `ResellSecrets/` (they're git-ignored; the project keeps
   red references to them):
   - `ResellSecrets/Keys.xcconfig` — backend URLs (wired as the app's base configuration)
   - `ResellSecrets/Supporting/GoogleService-Info.plist` — Firebase/Google config (bundled)
3. Build and run the `Resell` scheme.
