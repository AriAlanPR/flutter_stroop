import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stroop/providers/game_providers.dart'; // Import your providers
import 'package:flutter/services.dart'; // Import for keyboard input

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final score = ref.watch(scoreProvider);
    final remainingTime = ref.watch(timerProvider);
    final currentWord = ref.watch(currentWordProvider);

    // Start the game when the state is ready
    if (gameState == GameState.ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(gameLogicProvider).startGame();
      });
    }




    // Wrap the Scaffold with KeyboardListener
    return KeyboardListener(
      focusNode: FocusNode(), // Needs a FocusNode to receive keyboard events
      autofocus: true, // Automatically focus when the widget is built
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          // Handle key down events
          final gameLogic = ref.read(gameLogicProvider);
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            gameLogic.checkAnswer(Direction.right);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            gameLogic.checkAnswer(Direction.left);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            gameLogic.checkAnswer(Direction.up);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            gameLogic.checkAnswer(Direction.down);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2196F3), // Primary color
          title: const Text('Stroop Game'),
        ),
        body: Center(
          // Wrap the main content with GestureDetector for swipes
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // Swipe Right
                ref.read(gameLogicProvider).checkAnswer(Direction.right);
              } else if (details.primaryVelocity! < 0) {
                // Swipe Left
                ref.read(gameLogicProvider).checkAnswer(Direction.left);
              }
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // Swipe Down
              } else if (details.primaryVelocity! < 0) {
                // Swipe Up
                ref.read(gameLogicProvider).checkAnswer(Direction.up);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Score and Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Score: $score', style: GoogleFonts.inter(fontSize: 24.0)),
                    Text('Time: $remainingTime', style: GoogleFonts.inter(fontSize: 24.0)),
                  ],
                ),
                const SizedBox(height: 50),
                // Word Display
                if (currentWord.isNotEmpty)
                  Text(
                    currentWord.keys.first,
                    style: GoogleFonts.inter(
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
                      Text('Tap to Start', style: GoogleFonts.inter(fontSize: 24.0)),
                      SizedBox(height: 20),
                      Text('Match Ink Color to Direction:', style: GoogleFonts.inter(fontSize: 20.0)),
                      Text('Red -> Right, Green -> Left, Blue -> Up, Yellow -> Down', style: GoogleFonts.inter(fontSize: 18.0)),
                    ],
                  ),
                if (gameState == GameState.gameOver)
                  Column(
                  children: [
                    Text('Game Over!', style: GoogleFonts.inter(fontSize: 48.0)),
                    Text('Final Score: $score', style: GoogleFonts.inter(fontSize: 24.0)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(scoreProvider.notifier).state = 0;
                        ref.read(timerProvider.notifier).state = 30;
                        ref.read(currentWordProvider.notifier).state = {};
                        ref.read(gameStateProvider.notifier).state = GameState.ready;
                        ref.read(gameLogicProvider).startGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Restart Game',
                        style: GoogleFonts.inter(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
