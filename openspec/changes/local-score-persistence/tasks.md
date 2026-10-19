# Tasks: local-score-persistence

## 1. StorageService and unit tests
- [x] 1.1 Add `shared_preferences` dependency to `pubspec.yaml`
- [x] 1.2 Implement `StorageService` in `lib/model/services/storage_service.dart` with high score and games played methods
- [x] 1.3 Add unit tests in `test/storage_service_test.dart` implementing the storage scenarios with exact name parity

## 2. State management and game session persistence integration
- [x] 2.1 Implement `score_providers.dart` in `lib/model/state/score_providers.dart` exposing reactive high score
- [x] 2.2 Connect `GameNotifier` to trigger `recordGamePlayed` on `StorageService` when transitioning to `gameOver`
- [x] 2.3 Verify state integration with tests in `test/game_notifier_test.dart`

## 3. UI presentation and widget tests
- [ ] 3.1 Update `MainMenuScreen` to display the current high score with a semantic key
- [ ] 3.2 Update `GameOverView` to indicate whether a new high score was achieved
- [ ] 3.3 Add widget tests in `test/score_ui_test.dart` implementing the UI scenarios with exact name parity
- [ ] 3.4 Run repository verification (`flutter test` and `flutter analyze`) and ensure all checks pass cleanly
