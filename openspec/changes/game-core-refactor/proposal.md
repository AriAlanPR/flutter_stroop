# Change: game-core-refactor

## Motivation
The current game state in `flutter_stroop` is fragmented across multiple independent `StateProvider` instances (`gameStateProvider`, `scoreProvider`, `timerProvider`, `currentChallengeProvider`, `correctAnswersProvider`, `totalAttemptsProvider` in `lib/providers/game_providers.dart:36-51`). The countdown timer lives inside a global `Provider` without `.autoDispose` (`lib/providers/game_providers.dart:76-142`), causing timer leaks when navigating back from `GameScreen`. Furthermore, game state resets are duplicated across UI screens (`lib/screens/main_menu_screen.dart:61-64` and `lib/screens/game_screen.dart:120-126`), and existing tests in `test/widget_test.dart` are broken/outdated.

Refactoring the core game logic into a cohesive Riverpod `Notifier` with an immutable state model (`lib/model/game_session.dart` and `lib/model/state/game_notifier.dart`) establishes a clean architecture (SoC/SRP) conforming to project rules, fixes memory/timer leaks, and provides a solid foundation for persistence and advanced metrics.

## What Changes
- Create immutable models `GameSession` and `WordChallenge` under `lib/model/`.
- Create `GameNotifier` (Riverpod `Notifier<GameSession>` or `AutoDisposeNotifier<GameSession>`) in `lib/model/state/game_notifier.dart` managing start, timer countdown, answer checking, and clean disposal.
- Refactor `GameScreen` and `MainMenuScreen` to consume the unified `gameNotifierProvider`.
- Cleanly cancel and dispose timers when leaving `GameScreen` or stopping a game.
- Replace the obsolete counter test in `test/widget_test.dart` and create unit tests for `GameNotifier` with 100% scenario parity.

## Non-goals (Out of Scope)
- Local disk persistence or database storage (deferred to `local-score-persistence`).
- UI themes / Dark mode overhaul or sound effects.
- Leaderboards or cloud sync.
- Adding complex animation loaders from `lib/utils/flutterfx/`.

## Impact
- **Architecture**: Adopts layered architecture: `lib/model/` (data/models) and `lib/model/state/` (Riverpod notifiers) according to workspace rules.
- **Affected files**:
  - `lib/model/game_session.dart` (new)
  - `lib/model/state/game_notifier.dart` (new)
  - `lib/providers/game_providers.dart` (deprecated/removed in favor of `lib/model/state/`)
  - `lib/screens/game_screen.dart` (updated provider references)
  - `lib/screens/main_menu_screen.dart` (updated start action)
  - `test/game_notifier_test.dart` (new unit tests)
  - `test/widget_test.dart` (updated smoke test)

## Decisions and Alternatives
- **Decision: Immutable `GameSession` with `copyWith`**:
  - *Alternative discarded*: Keeping 6 individual `StateProvider`s. Discarded because multi-variable mutations from UI widgets cause partial update race conditions and make unit testing difficult.
- **Decision: Riverpod 2 `Notifier` / `AutoDisposeNotifier`**:
  - *Alternative discarded*: Using `ChangeNotifier` or raw `StatefulWidget`. Discarded to maintain strict Riverpod architecture and testability without UI dependencies.
- **Decision: Explicit lifecycle cleanup on game exit**:
  - *Alternative discarded*: Relying on GC. Discarded because `dart:async` `Timer.periodic` holds references and leaks in background if not canceled explicitly.
