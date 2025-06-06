import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

enum GameState {
  initial, // Added an initial state before ready
  ready,
  playing,
  gameOver,
}

final scoreProvider = StateProvider<int>((ref) => 0);

final timerProvider = StateProvider<int>((ref) => 30); // Starting with 30 seconds

final currentWordProvider = StateProvider<Map<String, Color>>((ref) => {}); // Initialize with empty map

final gameStateProvider = StateProvider<GameState>((ref) => GameState.ready);

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

  void generateNewWord() {
    final random = Random();
    final word = words[random.nextInt(words.length)];
    final color = colors[random.nextInt(colors.length)];
    currentWordNotifier.state = {word: color};
  }

  void startGame() {
    gameStateNotifier.state = GameState.playing;
    scoreNotifier.state = 0;
    timerNotifier.state = 30; // Reset timer
    generateNewWord();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerNotifier.state > 0) {
        timerNotifier.state--;
      } else {
        gameTimer?.cancel();
        gameStateNotifier.state = GameState.gameOver;
      }
    });
  }

  void stopGame() {
      gameTimer?.cancel();
      gameStateNotifier.state = GameState.gameOver;
  }

  // Add other game logic methods here (e.g., checkAnswer)

  return GameLogic(
    startGame: startGame,
    generateNewWord: generateNewWord,
    stopGame: stopGame,
    // Expose other methods
  );
});

// Simple class to hold game logic functions
class GameLogic {
  final VoidCallback startGame;
  final VoidCallback generateNewWord;
  final VoidCallback stopGame;
  // Add other function types

  GameLogic({required this.startGame, required this.generateNewWord, required this.stopGame});
}