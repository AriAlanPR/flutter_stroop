# Change: game-mechanics-stats

## Motivation
With the core state unified (`game-core-refactor`) and local score persistence established (`local-score-persistence`), the game currently only tracks raw scores and overall attempt ratios. The Stroop effect is fundamentally a cognitive psychology test of reaction time interference: identifying ink color is significantly slower and more error-prone when the word name conflicts with the ink color (incongruent condition) than when they match (congruent condition).

This change enriches the gameplay mechanics by tracking individual stimulus reaction times in milliseconds, measuring cognitive interference (congruent vs. incongruent stimulus accuracy), and displaying a comprehensive post-game statistics summary screen.

## What Changes
- Enhance `WordChallenge` and `GameSession` in `lib/model/game_session.dart` to track congruency (`isCongruent`) and stimulus exposure timestamps.
- Update `GameNotifier` in `lib/model/state/game_notifier.dart` to measure reaction time on each player response and aggregate performance metrics (average reaction time, best reaction time, congruent vs incongruent accuracy).
- Refactor `GameOverView` in `lib/screens/game_screen.dart` to present an interactive stats card (Avg Reaction Time, Accuracy %, Interference breakdown).
- Add unit and widget tests validating reaction time tracking and metrics calculation with 100% scenario parity.

## Non-goals (Out of Scope)
- Sound FX or audio synthesizer integration.
- Online leaderboards or multiplayer matchmaking.
- Custom color theme builders or skin shops.

## Impact
- **Domain Models**: Enriches `GameSession` with cognitive metrics.
- **Affected files**:
  - `lib/model/game_session.dart` (adds reaction time lists, congruency counters, computed getters)
  - `lib/model/state/game_notifier.dart` (captures reaction timestamps)
  - `lib/screens/game_screen.dart` (expands stats dashboard in GameOverView)
  - `test/game_stats_test.dart` (new unit tests)
  - `test/game_screen_stats_test.dart` (new widget tests)

## Decisions and Alternatives
- **Decision: In-memory detailed trial metrics during play, aggregated summary on completion**:
  - *Alternative discarded*: Writing each individual millisecond tap to disk during active gameplay. Discarded to prevent unnecessary disk I/O and frame drops during fast swipes.
- **Decision: Computed congruency based on word name vs ink color**:
  - *Alternative discarded*: Hardcoded separate challenge classes. Discarded to maintain KISS and reuse the existing challenge structure.
