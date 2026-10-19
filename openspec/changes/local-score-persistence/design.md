# Design: local-score-persistence

## Architecture and Layering

Conforming to workspace rules (`flutter-coding-guide.md` §0, §1 and §3):
- **Model / Service (`lib/model/services/`)**:
  - `lib/model/services/storage_service.dart`: Encapsulates access to local preferences with the mandatory `Service` suffix:
    ```dart
    class StorageService {
      final SharedPreferences _prefs;
      const StorageService(this._prefs);

      int getHighScore();
      Future<bool> saveHighScore(int score);
      int getTotalGamesPlayed();
      Future<bool> incrementGamesPlayed();
    }
    ```
- **State (`lib/model/state/`)**:
  - `lib/model/state/score_providers.dart`:
    - `sharedPreferencesProvider`: Provides the `SharedPreferences` instance.
    - `storageServiceProvider`: Instantiates `StorageService`.
    - `highScoreProvider`: Reactive `StateNotifier` or `Notifier<int>` exposing the current high score and saving updates when a game ends.
- **View (`lib/screens/`)**:
  - `lib/screens/main_menu_screen.dart`: Observes `highScoreProvider` and displays "Best: $highScore".
  - `lib/screens/game_screen.dart`: On `GameOverView`, checks if the game's final score surpassed the previous high score and renders a "New High Score!" highlight.

## Contracts and Interfaces

```dart
// lib/model/services/storage_service.dart
class StorageService {
  static const String keyHighScore = 'stroop_high_score';
  static const String keyTotalGames = 'stroop_total_games';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  int getHighScore() => _prefs.getInt(keyHighScore) ?? 0;

  Future<bool> saveHighScore(int score) async {
    final current = getHighScore();
    if (score > current) {
      return _prefs.setInt(keyHighScore, score);
    }
    return false;
  }

  int getTotalGamesPlayed() => _prefs.getInt(keyTotalGames) ?? 0;

  Future<bool> recordGamePlayed(int finalScore) async {
    final currentGames = getTotalGamesPlayed();
    await _prefs.setInt(keyTotalGames, currentGames + 1);
    await saveHighScore(finalScore);
    return true;
  }
}
```

## Testing Strategy
- Unit test suite: `test/storage_service_test.dart`
  - Strict 1:1 Scenario parity with `specs/score-persistence/spec.md`:
    - `Initial launch with no saved records defaults high score to zero`
    - `Achieving a score higher than current high score updates record`
    - `Achieving a score lower than current high score preserves record`
- Widget test suite: `test/score_ui_test.dart`
  - Strict 1:1 Scenario parity for UI scenarios:
    - `Main menu displays current high score`
    - `Game over screen indicates new high score achieved`
  - Uses `SharedPreferences.setMockInitialValues(...)` to verify UI components deterministically without physical disk I/O.
