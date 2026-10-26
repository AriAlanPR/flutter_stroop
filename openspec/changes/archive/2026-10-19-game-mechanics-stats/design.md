# Design: game-mechanics-stats

## Architecture and Layering

Conforming to workspace rules (`flutter-coding-guide.md` §0, §1 and §3):
- **Model (`lib/model/`)**:
  - `lib/model/game_session.dart`:
    - `WordChallenge`: Adds computed boolean getter `bool get isCongruent`:
      ```dart
      bool get isCongruent => kStroopColorMap[word] == color;
      ```
    - `GameSession`: Adds fields and getters:
      ```dart
      final List<int> reactionTimesMs;
      final int congruentAttempts;
      final int congruentCorrect;
      final int incongruentAttempts;
      final int incongruentCorrect;

      int get averageReactionTimeMs => reactionTimesMs.isEmpty
          ? 0
          : (reactionTimesMs.reduce((a, b) => a + b) / reactionTimesMs.length).round();

      int get bestReactionTimeMs => reactionTimesMs.isEmpty
          ? 0
          : reactionTimesMs.reduce((a, b) => a < b ? a : b);

      double get congruentAccuracy =>
          congruentAttempts == 0 ? 0.0 : (congruentCorrect / congruentAttempts) * 100.0;

      double get incongruentAccuracy =>
          incongruentAttempts == 0 ? 0.0 : (incongruentCorrect / incongruentAttempts) * 100.0;
      ```
- **State (`lib/model/state/`)**:
  - `lib/model/state/game_notifier.dart`:
    - Tracks `DateTime _stimulusShownAt` when generating challenges.
    - Exposes clock provider `clockProvider = Provider<DateTime Function()>((ref) => DateTime.now)` to enable deterministic time testing without `Future.delayed`.
    - In `checkAnswer()`, computes `final elapsedMs = clock().difference(_stimulusShownAt).inMilliseconds;` and updates trial metrics.
- **View (`lib/screens/`)**:
  - `lib/screens/game_screen.dart` (`GameOverView`):
    - Displays a statistics summary board with semantic keys:
      - `avg_reaction_time_chip`: "Avg: ${session.averageReactionTimeMs}ms"
      - `accuracy_chip`: "Accuracy: ${session.accuracy.toStringAsFixed(1)}%"
      - `congruency_breakdown_chip`: "Congruent: ${session.congruentAccuracy.toStringAsFixed(0)}% | Incongruent: ${session.incongruentAccuracy.toStringAsFixed(0)}%"

## Testing Strategy
- Unit test suite: `test/game_stats_test.dart`
  - Strict 1:1 Scenario parity with `specs/game-stats/spec.md`:
    - `Congruent stimulus matching word and ink color is identified`
    - `Incongruent stimulus with conflicting word and ink color is identified`
    - `Player response records reaction time in milliseconds`
- Widget test suite: `test/game_screen_stats_test.dart`
  - Strict 1:1 Scenario parity for UI scenarios:
    - `Game over screen displays average reaction time`
    - `Game over screen displays cognitive congruency accuracy breakdown`
