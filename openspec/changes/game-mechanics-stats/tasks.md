# Tasks: game-mechanics-stats

## 1. Congruency and reaction time model extensions
- [x] 1.1 Extend `WordChallenge` and `GameSession` in `lib/model/game_session.dart` with congruency and reaction time metrics
- [x] 1.2 Update `GameNotifier` in `lib/model/state/game_notifier.dart` to track stimulus timestamps and record millisecond reaction times
- [x] 1.3 Add unit tests in `test/game_stats_test.dart` implementing the model and tracking scenarios with exact name parity

## 2. GameOverView stats dashboard and UI tests
- [x] 2.1 Refactor `GameOverView` in `lib/screens/game_screen.dart` to render average reaction time and congruency breakdown
- [x] 2.2 Add widget tests in `test/game_screen_stats_test.dart` implementing the UI scenarios with exact name parity

## 3. Full suite verification and theme token cleanup
- [x] 3.1 Clean up hardcoded style colors in stats chips using Theme tokens
- [x] 3.2 Run repository verification (`flutter test` and `flutter analyze`) and ensure all checks pass cleanly
