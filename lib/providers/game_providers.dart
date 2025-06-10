import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

enum GameState {
  ready,
  playing,
  gameOver,
}

// Define directions
enum Direction { 
  right, 
  left, 
  up, 
  down 
}


final scoreProvider = StateProvider<int>((ref) => 0);

final timerProvider = StateProvider<int>((ref) => 30); // Starting with 30 seconds

final currentWordProvider = StateProvider<Map<String, Color>>((ref) => {}); // Initialize with empty map

final gameStateProvider = StateProvider<GameState>((ref) => GameState.ready);


// Mapping of colors to directions
final Map<Color, Direction> colorDirectionMap = {
  Colors.red: Direction.right,
  Colors.green: Direction.left,
  Colors.blue: Direction.up,
  Colors.yellow: Direction.down,
};
// Define the possible words and colors
final List<String> words = ['RED', 'GREEN', 'BLUE', 'YELLOW'];
final List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];

// Provider for the game logic and actions
final gameLogicProvider = Provider((ref) {
  final scoreNotifier = ref.read(scoreProvider.notifier);
  final timerNotifier = ref.read(timerProvider.notifier);
  final currentWordNotifier = ref.read(currentWordProvider.notifier);
  final gameStateNotifier = ref.read(gameStateProvider.notifier);

  Timer? gameTimer;

  // Dispose the timer when the provider is disposed
  ref.onDispose(() {
    gameTimer?.cancel();
  });

  void generateNewWord() {
    final random = Random();
    final word = words[random.nextInt(words.length)];
    final color = colors[random.nextInt(colors.length)];
    currentWordNotifier.state = {word: color};
  }

  void startGame() {
    gameTimer?.cancel(); // Cancel any existing timer
    gameTimer = null; // Ensure the reference is cleared

    gameStateNotifier.state = GameState.playing;
    scoreNotifier.state = 0;
    timerNotifier.state = 30; // Reset timer
    generateNewWord();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerNotifier.state > 0) {
        timerNotifier.state--;
      } else {
        gameTimer?.cancel();
        gameTimer = null; // Clear reference after cancellation
        gameStateNotifier.state = GameState.gameOver;
      }
    });
  }

  void stopGame() {
      gameTimer?.cancel();
      gameTimer = null; // Clear reference after cancellation
      gameStateNotifier.state = GameState.gameOver;
  }

  void checkAnswer(Direction inputDirection) {
    if (gameStateNotifier.state != GameState.playing) return;

    final currentWordEntry = currentWordNotifier.state;
    if (currentWordEntry.isEmpty) return;

    final inkColor = currentWordEntry.values.first;
    final correctDirection = colorDirectionMap[inkColor];

    if (inputDirection == correctDirection) {
      scoreNotifier.state++;
      timerNotifier.state = timerNotifier.state + 2 > 30 ? 30 : timerNotifier.state + 2; // Add 2 seconds bonus, max 30
    } else {
      timerNotifier.state = timerNotifier.state - 1 < 0 ? 0 : timerNotifier.state - 1; // Subtract 1 second penalty, min 0
    }

    generateNewWord(); // Generate a new word after each answer
  }

  // Add other game logic methods here (e.g., checkAnswer)

  return GameLogic(
    startGame: startGame,
    generateNewWord: generateNewWord,
    stopGame: stopGame,
    checkAnswer: checkAnswer,
  );
});

// Class to hold game logic functions
class GameLogic {
  final VoidCallback startGame;
  final VoidCallback generateNewWord;
  final VoidCallback stopGame; // Consider making this accept a parameter if needed for final score handling
  final void Function(Direction) checkAnswer;

  GameLogic({required this.startGame, required this.generateNewWord, required this.stopGame, required this.checkAnswer});
}