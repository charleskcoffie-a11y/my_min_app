<!-- .github/copilot-instructions.md -->
# Copilot / AI Agent Instructions for my_min_app

Purpose: help an AI coding assistant be productive in this Flutter multi-platform app.

1) Project Big Picture
- **Type**: Flutter app (multi-platform) with platform folders for `android/`, `ios/`, `linux/`, `windows/`, `macos/`, `web/`.
- **Entry point**: `lib/main.dart` — initializes Supabase and creates the `GeminiService` then passes it to screens.
- **Core layers**: `lib/core/` (shared services & theme), `lib/features/` (screens by feature), `lib/models/` (data models), `lib/widgets/` (UI components).
- **Why structured this way**: features are screen-focused and receive shared services via constructor injection (see `GeminiService` passed into `DevotionScreen`, `CounsellingScreen`, `TasksScreen` in `main.dart`). Prefer continuation of this pattern when adding features.

2) Key files & examples
- `lib/core/gemini_service.dart`: simple HTTP wrapper calling Google Generative Language (Gemini). It accepts an `apiKey` in the constructor and exposes `generateText(String)`.
- `lib/secrets.dart`: contains `supabaseUrl` and `supabaseAnonKey` constants and is imported by `main.dart`. NOTE: this repo currently stores keys here for a personal app — avoid committing new secrets; follow repo policy (below) if making changes.
- `lib/core/app_theme.dart`: centralized Material theme using Material 3. Use this for consistent UI styles.
- `lib/features/*/*_screen.dart`: screens follow a pattern of constructor injection for services. Use that approach rather than global singletons.

3) Service boundaries & data flows
- Supabase: initialized in `main.dart` via `Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey)`. Database/network IO goes through Supabase SDK and HTTP in `GeminiService`.
- GeminiService: performs direct HTTP POST to `generativelanguage.googleapis.com` and expects `candidates[0].content.parts[0].text`. Handle errors the same way (throw Exceptions) or follow existing error handling strategy.
- Passing dependencies: the app prefers passing `GeminiService` instances into widgets/screens. Follow that DI pattern for new services.

4) Project-specific conventions
- Configuration/secrets: `lib/secrets.dart` currently holds keys. For collaborative work or open-source contributions, **do not commit secrets** — instead create a local `lib/secrets_private.dart` (gitignored) or use environment variables and update `README.md` with instructions. If you modify secrets handling, update `lib/main.dart` to load whichever pattern the repo chooses.
- UI & Theme: Centralized in `lib/core/app_theme.dart`. Reuse `AppTheme.lightTheme` for new Material apps/screens.
- HTTP & async: network calls use `http` package and explicit `throw Exception(...)` on bad statuses. Keep similar error patterns for parity unless adding a global error handler.
- Null-safety & SDK: The project uses Dart SDK `^3.10.3`. Maintain null-safety and avoid downgrading language features.

5) Developer workflows & commands (Windows / cmd.exe examples)
- Install deps: `flutter pub get`
- Run on connected device: `flutter run -d <deviceId>`
- Build Android debug APK: `flutter build apk` or `cd android && gradlew.bat assembleDebug` (Gradle Kotlin `.kts` is used)
- Build iOS: open `ios/Runner.xcworkspace` in Xcode (macOS) or `flutter build ios` on macOS
- Run tests: `flutter test`
- Analyze/lint: project uses `flutter_lints` (see `analysis_options.yaml`). Run `flutter analyze`.

6) Where to look for changes and common edits
- Adding a new feature: create `lib/features/<feature>/` with `<feature>_screen.dart` and wire services through constructors. Register any models in `lib/models`.
- Adding platform code: platform glue lives in each platform folder; Android uses Gradle Kotlin scripts in `android/` and `app/`.
- Localization/assets: look at `build/flutter_assets` for produced assets; add assets in `pubspec.yaml` if needed.

7) Safety + secrets policy (repo-specific)
- This repo currently keeps Supabase keys in `lib/secrets.dart` for personal convenience. For any PR or shared branch:
  - Replace keys with placeholders and add guidance to `README.md`.
  - Use a local-only secrets file (e.g., `lib/secrets_private.dart`) and add it to `.gitignore`.
  - Alternatively, prefer CI/OS environment variables and document them.

8) Tests, CI, and automation
- There are no CI config files checked in for GitHub Actions here. If you add tests, include a lightweight workflow to run `flutter test` on PRs.

9) How AI assistants should make edits
- Small, focused PRs: follow the repo's file structure; prefer constructor DI for new services.
- Avoid adding secrets. If a change requires credentials, add clear instructions and placeholders.
- Keep changes minimal and within the existing style (no global refactors without approval).

If anything here is unclear or you'd like more detail (example PR template, CI workflow, or secrets migration), tell me which part to expand and I'll update this document.
