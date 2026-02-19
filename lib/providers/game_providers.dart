import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';

// --- ENUMS ---

// Represents the overall state of the game.
enum GameState {
  ready,       // Before the game starts, showing instructions.
  playing,     // The game is active.
  gameOver,    // The game has ended.
}

// Represents the four cardinal directions for player input.
enum Direction {
  up,
  down,
  left,
  right,
}

// --- MODELS ---

// Holds the challenge data: the word displayed and its ink color.
class WordChallenge {
  final String word;
  final Color color;

  WordChallenge({required this.word, required this.color});
}

// --- STATE PROVIDERS ---

// Manages the game's current state (ready, playing, gameOver).
final gameStateProvider = StateProvider<GameState>((ref) => GameState.ready);

// Manages the player's score.
final scoreProvider = StateProvider<int>((ref) => 0);

// Manages the countdown timer.
final timerProvider = StateProvider<int>((ref) => 30);

// Holds the current word challenge.
final currentChallengeProvider = StateProvider<WordChallenge?>((ref) => null);

// Tracks total correct answers for accuracy calculation.
final correctAnswersProvider = StateProvider<int>((ref) => 0);

// Tracks total attempts for accuracy calculation.
final totalAttemptsProvider = StateProvider<int>((ref) => 0);


// --- GAME CONFIGURATION ---

// Maps color names to their respective Color objects.
final Map<String, Color> colorMap = {
  'RED': Colors.red,
  'GREEN': Colors.green,
  'BLUE': Colors.blue,
  'YELLOW': Colors.yellow,
};

// Maps ink colors to the correct input direction.
final Map<Color, Direction> colorDirectionMap = {
  Colors.red: Direction.right,
  Colors.green: Direction.left,
  Colors.blue: Direction.up,
  Colors.yellow: Direction.down,
};


// --- GAME LOGIC ---

// Encapsulates all game actions and state transitions.
final gameLogicProvider = Provider((ref) {
  final random = Random();
  Timer? gameTimer;

  // Ensure the timer is cancelled when the provider is disposed.
  ref.onDispose(() => gameTimer?.cancel());

  // Generates a new word with a random ink color.
  void generateNewChallenge() {
    final word = colorMap.keys.elementAt(random.nextInt(colorMap.length));
    final color = colorMap.values.elementAt(random.nextInt(colorMap.length));
    ref.read(currentChallengeProvider.notifier).state = WordChallenge(word: word, color: color);
  }

  // Starts the game and initializes all state variables.
  void startGame() {
    gameTimer?.cancel();

    // Reset state for a new game.
    ref.read(gameStateProvider.notifier).state = GameState.playing;
    ref.read(scoreProvider.notifier).state = 0;
    ref.read(timerProvider.notifier).state = 30;
    ref.read(correctAnswersProvider.notifier).state = 0;
    ref.read(totalAttemptsProvider.notifier).state = 0;
    generateNewChallenge();

    // Start the game countdown timer.
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final timerNotifier = ref.read(timerProvider.notifier);
      if (timerNotifier.state > 0) {
        timerNotifier.state--;
      } else {
        gameTimer?.cancel();
        ref.read(gameStateProvider.notifier).state = GameState.gameOver;
      }
    });
  }

  // Processes the player's input and updates the game state.
  void checkAnswer(Direction swipe) {
    if (ref.read(gameStateProvider.notifier).state != GameState.playing) return;

    final challenge = ref.read(currentChallengeProvider.notifier).state;
    if (challenge == null) return;

    final correctDirection = colorDirectionMap[challenge.color];

    final scoreNotifier = ref.read(scoreProvider.notifier);
    final timerNotifier = ref.read(timerProvider.notifier);

    ref.read(totalAttemptsProvider.notifier).state++;

    if (swipe == correctDirection) {
      // Correct answer.
      scoreNotifier.state++;
      ref.read(correctAnswersProvider.notifier).state++;
      timerNotifier.state = min(99, timerNotifier.state + 1); // Add 1s, max 99.
    } else {
      // Incorrect answer.
      timerNotifier.state = max(0, timerNotifier.state - 2); // Subtract 2s, min 0.
    }

    generateNewChallenge(); // Load the next word.
  }

  return _GameLogic(startGame: startGame, checkAnswer: checkAnswer);
});

// Helper class to provide game logic functions to the UI.
class _GameLogic {
  final void Function() startGame;
  final void Function(Direction) checkAnswer;

  _GameLogic({required this.startGame, required this.checkAnswer});
}
