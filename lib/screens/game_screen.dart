import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async'; // Import for Timer
import 'package:myapp/providers/game_providers.dart'; // Import your providers

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Timer? _timer; // Declare the timer

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer in dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final score = ref.watch(scoreProvider);
    final remainingTime = ref.watch(timerProvider);
    final currentWord = ref.watch(currentWordProvider);

    // Start the game when the state is ready
    if (gameState == GameState.ready) {
      // We'll need a way to trigger startGame, perhaps a button
      // For now, let's assume the game starts automatically for testing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(gameStateProvider.notifier).state = GameState.playing;
        
        // Start the game when the state is ready
        if (gameState == GameState.ready) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Access gameLogicProvider and call startGame
            ref.read(gameLogicProvider).startGame();
          });
        }
      });
    }

    // Implement timer logic when the game is playing
    if (gameState == GameState.playing) {
      _startTimer();
    } else {
      _timer?.cancel(); // Cancel timer if game is not playing
    }


    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3), // Primary color
        title: const Text('Stroop Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Score and Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Score: $score', style: TextStyle(fontSize: 24.0, fontFamily: 'Inter')),
                Text('Time: $remainingTime', style: TextStyle(fontSize: 24.0, fontFamily: 'Inter')),
              ],
            ),
            const SizedBox(height: 50),
            // Word Display
            if (currentWord.isNotEmpty)
              Text(
                currentWord.keys.first,
                style: TextStyle(
                  fontSize: 72.0,
                  color: currentWord.values.first,                  
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 50),
            // Placeholder for Instructions or Game Over Message
            if (gameState == GameState.ready)
              Column(
                children: [
                  Text('Tap to Start', style: TextStyle(fontSize: 24.0, fontFamily: 'Inter')),
                  SizedBox(height: 20),
                  Text('Match Ink Color to Direction:', style: TextStyle(fontSize: 20.0, fontFamily: 'Inter')),
                  Text('Red -> Right, Green -> Left, Blue -> Up, Yellow -> Down', style: TextStyle(fontSize: 18.0, fontFamily: 'Inter')),
                ],
              ),
            if (gameState == GameState.gameOver)
              Column(
                children: [
                  Text('Game Over!', style: TextStyle(fontSize: 48.0, fontFamily: 'Inter')),
                  Text('Final Score: $score', style: TextStyle(fontSize: 24.0, fontFamily: 'Inter')),
                  // Add accuracy and encouraging message later
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (ref.read(timerProvider.notifier).state > 0) {
        ref.read(timerProvider.notifier).state--;
      } else {
        _timer?.cancel();
        ref.read(gameStateProvider.notifier).state = GameState.gameOver;
      }
    });
  }
}
