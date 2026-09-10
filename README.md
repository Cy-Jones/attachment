# Attachment

Attachment is a couples companion mobile app built with Flutter. It provides features to help partners connect, onboard together, chat, and maintain shared spaces — backed by Firebase for authentication and persistence.

## Key features
- Sign-in / authentication (Firebase)
- Onboarding flows for new users and couples
- Real-time chat
- Shared "spaces" for photo or message collections
- Modular feature structure (auth, onboarding, chat, space)
- Offline/online handling and connectivity checks

## Stack
- **Language:** Dart (Flutter)
- **Framework / runtime:** Flutter (Dart 3 / Flutter 3.x+)
- **State management:** Riverpod (flutter_riverpod)
- **Navigation:** go_router
- **Backend:** Firebase (Core, Auth, Firestore)
- **Notable libraries:** google_fonts, flutter_svg, connectivity_plus

## Quick start — run locally
Prerequisites:
- Flutter SDK (compatible with Dart >= 3.11)
- Xcode (macOS) for iOS or Android SDK / Android Studio for Android
- A Firebase project (the repo contains a firebase options file; see Firebase section)

Install and run:
```bash
# fetch dependencies
flutter pub get

# run on connected device / emulator
flutter run
```

Build release artifacts:
```bash
# Android APK
flutter build apk --release

# iOS (macOS + Xcode)
flutter build ios --release
```

Run tests:
```bash
flutter test
```

## Firebase
This project uses Firebase. A generated configuration is included at `lib/firebase_options.dart`. If you want to run the app with your own Firebase project:
1. Create a Firebase project and enable the services you need (Auth, Firestore, Storage, etc.).
2. Replace or regenerate the Firebase configuration (or update `lib/firebase_options.dart`) with your project's values.
3. Ensure `firebase.json` (present in repo) and any platform firebase config files match your Firebase project.

The app initializes Firebase at startup using platform-aware options; see `lib/main.dart` for the initialization and provider wiring.

## Project layout (top-level overview)
```
lib/
  main.dart                     # App entrypoint: initializes Firebase & runs MaterialApp.router
  firebase_options.dart         # Generated Firebase config (platform-aware)
  core/
    constants/                  # app-wide constants
    network/                    # connectivity / network helpers (connectivity wrapper)
    router/                     # go_router configuration
    theme/                      # theme data & theming helpers
    utils/                      # utility helpers
  features/
    auth/                       # authentication screens & logic
    onboarding/                 # onboarding flows
    chat/                       # chat UI & logic
    space/                      # shared spaces feature
  services/
    firebase_service.dart       # thin Firebase service wrapper
android/                        # Android platform project
ios/                            # iOS platform project
assets/                         # asset images and icons
pubspec.yaml                    # project manifest & dependencies
init_structure.sh               # helper script used during setup
test/                           # tests
```

How it fits together
- `main.dart` sets up Riverpod (`ProviderScope`) and initializes Firebase then runs `MaterialApp.router` with the app's `GoRouter`.
- Feature modules under `lib/features/*` contain UI, routing, and business logic for distinct areas (auth, chat, onboarding, space).
- `lib/core/*` provides shared cross-cutting concerns (theme, routing config, network/connectivity).
- `lib/services/firebase_service.dart` contains Firebase integration points used by features.

## Configuration & environment
- Check `pubspec.yaml` for exact dependency versions used by the project.
- The included `lib/firebase_options.dart` contains platform-specific Firebase settings; replace them for your own Firebase project.
- If the app uses environment-specific flavors or build configs, adjust platform build settings in `android/` and `ios/` accordingly.

## Development notes
- State management uses Riverpod and routing is powered by GoRouter — look in `lib/core/router` and `lib/core` for provider and theme patterns.
- Connectivity handling is encapsulated under `lib/core/network/connectivity_wrapper.dart` — the UI listens for connectivity status where appropriate.
- Assets are stored in `assets/` and referenced from `pubspec.yaml`.

## Contributing
- Open an issue for feature requests or bugs.
- Follow the existing code organization: add features under `lib/features/<feature-name>`.
- Run `flutter test` and ensure existing tests pass before opening PRs.
- Add brief notes to `CHANGELOG` or PR description explaining the change.

## Known / next steps (suggested)
- Add or update CONTRIBUTING.md and CODE_OF_CONDUCT.md
- Add CI workflows for linting, testing, and building release artifacts
- Provide clearer docs for Firebase project setup (if sharing this repo)

## Contact
Project maintained by the repository owner. For questions, open an issue or reach out via the repository discussion/PRs.
