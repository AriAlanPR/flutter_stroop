# Design: game-core-refactor

## Architecture and Layering

Conforming to workspace rules (`flutter-coding-guide.md` §0 and §1):
- **Model (`lib/model/`)**:
  - `lib/model/game_session.dart`: Defines immutable data structures:
    - `enum GameState { ready, playing, gameOver }`
    - `enum Direction { up, down, left, right }`
    - `class WordChallenge { final String word; final Color color; }`
    - `class GameSession`: Contains `gameState`, `score`, `timer`, `currentChallenge`, `correctAnswers`, `totalAttempts`, plus computed property `accuracyPercentage`. Provides `copyWith()`.
- **State (`lib/model/state/`)**:
  - `lib/model/state/game_notifier.dart`: Implements `GameNotifier extends AutoDisposeNotifier<GameSession>` (or `Notifier<GameSession>` with explicit dispose handling).
    - Encapsulates `startGame()`, `stopGame()`, `checkAnswer(Direction)`, and internal `_generateChallenge()`.
    - Holds `Timer? _gameTimer` cancelled in `ref.onDispose()` and when game ends.
    - Exposes `gameNotifierProvider`.
- **View (`lib/screens/` and `lib/widgets/`)**:
  - `lib/screens/game_screen.dart`: Observes `gameNotifierProvider`. Dispatches `startGame()` via post-frame callback if `ready`, forwards keyboard and swipe events to `ref.read(gameNotifierProvider.notifier).checkAnswer(direction)`.
  - `lib/screens/main_menu_screen.dart`: Resets game state via `ref.read(gameNotifierProvider.notifier).resetGame()` or navigating cleanly to `GameScreen`.

## Contracts and Interfaces

```dart
// lib/model/game_session.dart
class GameSession {
  final GameState gameState;
  final int score;
  final int timer;
  final WordChallenge? currentChallenge;
  final int correctAnswers;
  final int totalAttempts;

  const GameSession({
    this.gameState = GameState.ready,
    this.score = 0,
    this.timer = 30,
    this.currentChallenge,
    this.correctAnswers = 0,
    this.totalAttempts = 0,
  });

  double get accuracy => totalAttempts == 0 ? 0.0 : (correctAnswers / totalAttempts) * 100;

  GameSession copyWith({...});
}
```

```dart
// lib/model/state/game_notifier.dart
class GameNotifier extends AutoDisposeNotifier<GameSession> {
  @override
  GameSession build() {
    ref.onDispose(() => _cancelTimer());
    return const GameSession();
  }

  void startGame();
  void stopGame();
  void checkAnswer(Direction inputDirection);
  void resetGame();
}
```

## Lifecycle and Resource Management
- In `lib/providers/game_providers.dart:81`, `ref.onDispose` was never called when popping `GameScreen` because the provider was not auto-disposable.
- By configuring `AutoDisposeNotifier` for `gameNotifierProvider`, leaving the screen automatically cleans up the provider and executes `_cancelTimer()`.
- If the game is restarted on the same screen (`Restart Game`), existing timer is explicitly cancelled before creating a new `Timer.periodic`.

## Testing Strategy
- Unit test suite: `test/game_notifier_test.dart`
  - Strict 1:1 Scenario parity with `specs/game-core/spec.md`:
    - `Starting a new game initializes playing session`
    - `Timer decrements periodically until zero and ends game`
    - `Leaving game cancels timer and cleans up resources`
    - `Correct answer increases score and adds bonus time`
    - `Incorrect answer penalizes time without increasing score`
    - `Submitting input when game is not playing is ignored`
- Smoke / Widget test: `test/widget_test.dart`
  - Replaces obsolete counter test with a test that renders `MainMenuScreen` inside `ProviderScope` and verifies main title and buttons render correctly.
