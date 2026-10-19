# Tasks: game-core-refactor

## 1. Model and GameNotifier implementation
- [x] 1.1 Create immutable `GameSession` and `WordChallenge` models in `lib/model/game_session.dart`
- [x] 1.2 Implement `GameNotifier` with `AutoDisposeNotifier` in `lib/model/state/game_notifier.dart` managing start, timer, score, accuracy, and timer cancellation
- [x] 1.3 Add unit tests in `test/game_notifier_test.dart` implementing the scenarios with exact name parity

## 2. Screen integration and provider migration
- [x] 2.1 Refactor `lib/screens/game_screen.dart` to consume `gameNotifierProvider` and dispatch actions cleanly
- [x] 2.2 Refactor `lib/screens/main_menu_screen.dart` to eliminate manual multiple provider resets
- [x] 2.3 Remove or redirect legacy `lib/providers/game_providers.dart` to prevent duplicate state sources

## 3. Widget test repair and verification
- [ ] 3.1 Update `test/widget_test.dart` to test `MainMenuScreen` smoke rendering instead of obsolete counter
- [ ] 3.2 Run repository verification (`flutter test` and `flutter analyze`) and ensure all checks pass cleanly
