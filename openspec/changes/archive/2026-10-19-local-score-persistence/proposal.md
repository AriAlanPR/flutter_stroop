# Change: local-score-persistence

## Motivation
With `game-core-refactor` completed, game state is cleanly unified in `GameNotifier`. However, all scores and statistics are still lost whenever the app is closed because there is no persistent storage. Players have no way to track their personal best score or see cumulative gameplay history.

This change introduces local on-device persistence using `shared_preferences`, creating a dedicated `StorageService` (`lib/model/services/storage_service.dart`) and integrating it with Riverpod so that high scores and game records survive application restarts.

## What Changes
- Add `shared_preferences: ^2.3.5` to `pubspec.yaml`.
- Create `StorageService` in `lib/model/services/storage_service.dart` with methods to read and write high scores, total games played, and last played stats.
- Create `ScoreNotifier` or integrate persistence into `lib/model/state/` so UI components reactively display the saved high score.
- Update `MainMenuScreen` to show the player's personal best (High Score).
- Update `GameOverView` on `GameScreen` to indicate when a new personal best has been achieved.
- Provide unit and widget tests with mock `SharedPreferences` to ensure 100% test scenario parity.

## Non-goals (Out of Scope)
- Cloud leaderboards, online accounts, or remote Firebase sync.
- Complex SQL queries or relational schemas (KISS / YAGNI).
- Millisecond reaction times and analytics (deferred to `game-mechanics-stats`).

## Impact
- **Dependencies**: Adds `shared_preferences` to `pubspec.yaml`.
- **Layering**: Introduces `lib/model/services/` conforming to workspace rule §1 ("Las clases de acceso a datos DEBEN usar el sufijo Service").
- **Affected files**:
  - `pubspec.yaml`
  - `lib/model/services/storage_service.dart` (new)
  - `lib/model/state/score_providers.dart` (new)
  - `lib/screens/main_menu_screen.dart` (displays high score)
  - `lib/screens/game_screen.dart` (highlights new high score on game over)
  - `test/storage_service_test.dart` (new unit tests)
  - `test/widget_test.dart` (updated)

## Decisions and Alternatives
- **Decision: `shared_preferences` with key-value pairs**:
  - *Alternative discarded*: `hive_ce` or SQLite/`drift`. Discarded because simple key-value storage completely fulfills the requirement for local high scores without binary code generation or heavy setup overhead.
- **Decision: Abstracted `StorageService`**:
  - *Alternative discarded*: Direct calls to `SharedPreferences.getInstance()` inside UI widgets. Discarded to maintain SRP/SoC and enable seamless mocking in tests.
