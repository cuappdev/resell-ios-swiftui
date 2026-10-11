# CLAUDE.md

Guidance for the Resell iOS (SwiftUI) rewrite. Match these conventions so new code reads like
what's already here. Architecture is standard **MVVM**, modeled on Cornell AppDev's Uplift app
(`uplift-ios-swiftui`). The legacy `resell-ios` repo is reference-only — don't copy its
patterns (it used a Router and scattered logic).

The three layers at a glance:

- **Model** — inert data. `Codable` value types, no logic, no SDK imports.
- **View** — only draws. Decomposed into small sub-views; no business logic.
- **ViewModel** — owns all logic and state. `@Observable`, nested in its view, one per screen.

General: self-documenting names over comments; `///` on non-trivial symbols, `//` only for
genuinely non-obvious logic. No narration, no commented-out code, no dead files.

---

## Model

- Inert `struct`s conforming to `Codable` / `Identifiable` / `Hashable` as needed. **No SDK
  imports in a model** — e.g. Google/Firebase mapping belongs in `GoogleAuthManager`, not `User`.
- Keep request/response payloads as plain structs (grouped `let`s, no wordy mapping inits).
  Don't add response wrappers or endpoints until a feature actually uses them.
- When identity is by `id`, implement `==` / `hash(into:)` on `id` only.
- Keep models as clean **domain** types. If the backend's wire shape differs from what the app
  wants, map it in an `init(from:)` rather than leaking wire concerns into views/VMs.
  Doc-comment (`///`) non-obvious properties.
- Live in `Models/`.

---

## View

Views only draw — all logic lives in the ViewModel.

**Composition**
- Split `body` into small `private var …: some View` sub-views. Like Uplift, a screen is many
  named sub-views, never one giant `body`.
- A `private func` is allowed only when it **returns a view** (a parameterized sub-view); it
  must never hold action or business logic.
- Button / `.onChange` closures are one-liners that call a VM method
  (`viewModel.signIn(main: mainViewModel)`), not blocks of logic.
- No magic values — colors, fonts, spacing, and layout numbers come from `Constants`.
- Every view file ends with a `#Preview` using dummy/fixture data — never a live network call.
- Sections: `// MARK: - Properties`, `// MARK: - UI`.

**State ownership**
- The owning view creates its VM with `@State private var viewModel = ViewModel()`.
- `@State` in a view is only for simple state tied directly to that view (a toggle, a local
  animation flag, a small filter selection). Once it grows logic or non-trivial use, move it to
  the ViewModel. When in doubt, it belongs in the VM.
- Use `@Bindable` on a receiving view only when it needs `$` bindings into a VM it doesn't own.

**Sharing a view model — pass the instance, don't use the environment**
- We avoid `@EnvironmentObject` / `@Environment` for view models: environment injection is
  invisible at the call site, has to be set up on every screen that might touch it, and a
  missed injection crashes at runtime.
- The view that needs another view's VM takes that owner's **existing instance** through its
  `init`, typed as the owner's nested `ViewModel`:
  ```swift
  struct ProductCell: View {
      let product: Product
      var viewModel: HomeView.ViewModel   // HomeView's instance
  }

  ProductCell(product: product, viewModel: viewModel)   // HomeView hands over its own
  ```
  Works for cells, sheets, pushed detail screens — one instance, the owner holds it with
  `@State`, everyone else receives a reference. Add `@Bindable` only if `$` bindings are needed.
- **The environment is reserved for app-wide state** (auth/session, the tab bar) where passing
  it everywhere isn't practical — inject with `.environment(instance)`, read with
  `@Environment(MainView.ViewModel.self)`. Be hesitant; default to passing the instance.

**Reuse & modifiers**
- Factor reusable behavior into `ViewModifier`s via `View` extensions instead of repeating
  overlay/presentation plumbing: `.loading(isLoading) { CustomProgressView() }`,
  `.showModal($flag) { … }`, shadow/shimmer, etc.
- Buttons use a shared `ScaleButtonStyle` (scale + slight dim on press); tactile feedback via
  `Haptics.shared.play(_:)`, not ad-hoc feedback generators.
- Shared, cross-feature components live in `Views/Components/`; a component used by only one
  feature lives in that feature's `Views/<Feature>/Components/`.

---

## ViewModel

- **`@Observable`, `@MainActor`, nested in the view it belongs to**, one per screen:
  ```swift
  extension LoginView {
      @MainActor
      @Observable
      final class ViewModel {
          var isLoading = false   // plain vars — no @Published / ObservableObject
      }
  }
  ```
  The file lives in `ViewModels/`, named `<Screen>ViewModel.swift`.
- **All complex logic lives here** — networking, image work, validation, session transitions.
  A child VM that advances the session takes `main: MainView.ViewModel` and sets
  `main.sessionState`.
- **Split animation out.** When a screen has meaningful animation state, keep it in a second,
  animation-only VM (e.g. `SignInAnimationViewModel`) separate from the logic VM.
- Sections: `// MARK: - Properties`, `// MARK: - Functions`, `// MARK: - Private`.

---

## Navigation

- **Top level** (onboarding ↔ main): `MainView.ViewModel` holds a `SessionState` enum;
  `ResellApp` switches on `mainViewModel.sessionState`. No `Router`.
- **Inside the app** (push product detail, seller profile, chat, …): each tab owns its own
  `NavigationStack(path:)`. Declare destinations **once** per stack with
  `.navigationDestination(for: Route.self)`, driven by a typed `Route` enum whose cases carry
  the `Hashable` model they need (e.g. `.productDetail(Product)`). Navigate by appending to the
  path — the path is `@State` on the tab root (or on the tab's VM when the VM needs to drive
  navigation). Don't scatter `NavigationLink(destination:)`; route through the enum.

## Screen state & errors

- **Content screens use one state enum**, not a pile of bools:
  ```swift
  enum LoadState<Value> { case loading, loaded(Value), empty, error(String) }
  ```
  The VM exposes `var state: LoadState<[Product]>`; the view switches on it. A plain
  `var isLoading = false` is fine only for a single action (e.g. a submit button), never for
  content loading.
- **Errors reach the UI through the VM:** expose `var errorMessage: String?` and present it with
  a shared `.errorAlert($viewModel.errorMessage)` modifier — one implementation, every screen
  consistent. Don't hand-roll a bespoke error sheet per screen.

## Services & networking

- All backend access goes through `NetworkManager` (`static let shared`), built on the generic
  `APIClient` templates (`get` / `post` / `delete`). Add an endpoint as a small `async` method
  that builds its URL with `constructURL(endpoint:)` and delegates to a template — never
  assemble a `URLRequest` in a feature. Requests route through `perform`, which injects the
  Bearer token and refreshes auth once on a `401`; decode with the shared `JSONDecoder` and
  surface failures as `ErrorResponse`.
- Auth flows through `GoogleAuthManager` (Google + Firebase) and `UserSessionManager`
  (restore / logout). Don't manage tokens elsewhere.
- **Singletons are the one allowed exception, and only for cross-cutting, app-lifetime
  services:** `NetworkManager`, `GoogleAuthManager`, `UserSessionManager`, `KeychainManager`,
  `Haptics`, `Logger` — `static let shared` + `private init()`. ViewModels and feature state are
  never singletons; the owner creates them and passes the instance down.

## Concurrency

- Modern Swift concurrency only (`async`/`await`, `Task`). No new Combine pipelines or raw
  `DispatchQueue` in feature code.
- Prefer `.task {}` over `.onAppear { Task {} }`. Reset flags like `isLoading` with `defer`.
- Guard against concurrent submits (single-flight) and disable buttons while loading.
- **Keep heavy work off the main actor.** Default actor isolation is MainActor, so JSON
  decoding and image work (resize / base64 / upload prep) would run on the main thread unless
  opted out — mark those paths `nonisolated` and hop back to the `@MainActor` VM only to
  publish results.
- **Cancellation.** `.task {}` cancels when the view disappears. For search-as-you-type or
  other debounced work, the VM stores the in-flight `Task` and cancels the previous one before
  starting the next.

## Data & media

- **Lists:** `List` / `LazyVStack` with stable `id`s. **Pagination:** the VM loads the next
  page when the last item appears (trigger from the last cell's `.onAppear` / `.task`); guard
  against overlapping page loads (single-flight).
- **Images:** listing / scrolling images go through the caching library (Kingfisher) via a
  shared `CachedImageView` — not raw `AsyncImage`, which re-fetches on scroll. `AsyncImage` is
  fine for a one-off, non-scrolling image. (Add Kingfisher when the first image-heavy feature
  lands.)
- **Fixtures:** preview data lives in `Resell/Preview Content/` (a Development Asset, excluded
  from release) as `static` mocks — `Product.mock`, `[Product].mocks`. Only previews use them;
  never reference a mock from shipping code.

## Constants, Keys & assets

- All colors, fonts, spacing, and per-screen layout numbers live in `Utils/Constants.swift` as
  nested enums (`Constants.Colors`, `Constants.Fonts`, `Constants.Login`, …). No inline hex,
  font literal, or layout number.
- All URLs, client IDs, and secrets come from `Keys` (reads the bundle). Never hardcode them.

## Logging

Use `Logger` (OSLog) categories — `Logger.services`, `Logger.data` — never `print`. Gate
debug-only logs behind `#if DEBUG`.

## Project layout

```
Resell/
  ResellApp.swift        @main; switches on sessionState; AppDelegate (Firebase)
  Models/                inert Codable value types + wire payloads
  Services/              GoogleAuthManager, UserSessionManager, KeychainManager, Logger
    Networking/          APIClient, NetworkManager
  Utils/
    Constants.swift      design tokens + per-screen layout enums
    Keys.swift           reads secrets from the bundle
    Extensions/          small focused extensions, one type per file
  ViewModels/            `extension <Screen> { ViewModel }`, one file per screen
  Views/
    MainView.swift       signed-in home
    Components/          ONLY components shared across multiple features
    Onboarding/          Login / SessionLoading / SetupProfile / Venmo
      Components/         components used by only this feature
ResellSecrets/           git-ignored secrets (red references in the project)
Info.plist               explicit; holds $(RESELL_*) keys, GIDClientID, URL scheme
Keys.xcconfig            base config (lives in ResellSecrets/)
```

## Build & project notes

- **Deployment target iOS 17.0.** Bundle id `com.cornellappdev.resell`.
- **SPM:** Firebase **12.x** + GoogleSignIn **10.x**. Firebase must stay 12.x — 13.x conflicts
  with GoogleSignIn via `app-check`.
- **`@Observable` ViewModels need no `import Combine`.** (Only legacy `ObservableObject` /
  `@Published` code does, because the project enables
  `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY`.)
- **Default actor isolation is MainActor** (`SWIFT_DEFAULT_ACTOR_ISOLATION`).
- **File-system-synchronized groups (objectVersion 77):** new files added under `Resell/`
  auto-compile — no need to edit `project.pbxproj` for source files.
- **Secrets** live as git-ignored red references under `ResellSecrets/` (`Keys.xcconfig` → base
  config, `Supporting/GoogleService-Info.plist` → bundled). Never commit real secret files.

## File header

```swift
//
//  <FileName>.swift
//  Resell
//
//  Created by <Author> on <M/D/YY>.
//
```

## Before you commit

- [ ] **Model:** inert, no SDK imports; payloads plain; identity on `id` only.
- [ ] **View:** split into many `private var …: some View`; no action `private func`s; thin
      closures; `#Preview` present; values from `Constants`.
- [ ] **View state:** owner holds VM with `@State`; shared VMs passed by instance (not the
      environment); `@State` only for simple view-local state.
- [ ] **ViewModel:** `@Observable @MainActor`, nested `extension <Screen> { ViewModel }`, one
      per screen; all complex logic here.
- [ ] Navigation: top level via `sessionState`; in-app via a `Route` enum +
      `.navigationDestination` — no scattered `NavigationLink`s.
- [ ] Content screens use a `LoadState` enum; errors surfaced via `errorMessage` + `.errorAlert`.
- [ ] Heavy work (decode / image) is `nonisolated`; debounced tasks cancel the previous one.
- [ ] Reusable behavior (loading / modals / etc.) factored into `ViewModifier`s.
- [ ] Shared components in `Views/Components/`; single-feature ones in the feature's folder.
- [ ] Preview fixtures live in `Preview Content/`, not referenced from shipping code.
- [ ] Network access via a `NetworkManager` endpoint; no inline `URLRequest`s; secrets from `Keys`.
- [ ] Errors logged via `Logger`, not `print`.
- [ ] Builds warning-free:
      `xcodebuild -scheme Resell -destination 'generic/platform=iOS Simulator' build`
