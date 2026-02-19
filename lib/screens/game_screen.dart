import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stroop/providers/game_providers.dart';
import 'package:stroop/widgets/instructions_dialog.dart';
import 'package:stroop/screens/main_menu_screen.dart';

// Main entry point for the game screen.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final FocusNode _focusNode;

  // Minimum velocity for a swipe to be registered, in pixels per second.
  static const double _minSwipeVelocity = 100.0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Start the game as soon as the screen is initialized.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameLogicProvider).startGame();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Helper method to show the instructions dialog.
  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const InstructionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    // The main scaffold listens for keyboard and gesture inputs.
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          _handleKeyPress(event.logicalKey, ref);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF3A3A3A), // Dark background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Stroop Focus', style: GoogleFonts.pressStart2p(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () => _showInstructions(context),
            ),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanEnd: (details) => _handleSwipe(details, ref),
          child: _buildGameStateView(gameState),
        ),
      ),
    );
  }

  Widget _buildGameStateView(GameState gameState) {
    switch (gameState) {
      case GameState.playing:
        return const GameView();
      case GameState.gameOver:
        return const GameOverView();
      case GameState.ready:
        // Show a loading indicator while the game is getting ready.
        return const Center(child: CircularProgressIndicator());
    }
  }

  // --- INPUT HANDLERS ---

  void _handleKeyPress(LogicalKeyboardKey key, WidgetRef ref) {
    final gameLogic = ref.read(gameLogicProvider);
    if (key == LogicalKeyboardKey.arrowUp) {
      gameLogic.checkAnswer(Direction.up);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      gameLogic.checkAnswer(Direction.down);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      gameLogic.checkAnswer(Direction.left);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      gameLogic.checkAnswer(Direction.right);
    }
  }

  void _handleSwipe(DragEndDetails details, WidgetRef ref) {
    final velocity = details.velocity.pixelsPerSecond;
    final gameLogic = ref.read(gameLogicProvider);

    if (velocity.distanceSquared > (_minSwipeVelocity * _minSwipeVelocity)) {
      if (velocity.dx.abs() > velocity.dy.abs()) {
        if (velocity.dx < 0) {
          gameLogic.checkAnswer(Direction.left);
        } else {
          gameLogic.checkAnswer(Direction.right);
        }
      } else {
        if (velocity.dy < 0) {
          gameLogic.checkAnswer(Direction.up);
        } else {
          gameLogic.checkAnswer(Direction.down);
        }
      }
    }
  }
}

// --- GAME STATE VIEWS ---

class GameView extends ConsumerWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(scoreProvider);
    final remainingTime = ref.watch(timerProvider);
    final challenge = ref.watch(currentChallengeProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InfoChip(label: 'Score', value: score.toString()),
              InfoChip(label: 'Time', value: remainingTime.toString()),
            ],
          ),
        ),
        const Spacer(),
        if (challenge != null)
          Text(
            challenge.word,
            style: GoogleFonts.pressStart2p(fontSize: 48.0, color: challenge.color),
          ),
        const Spacer(),
      ],
    );
  }
}

class GameOverView extends ConsumerWidget {
  const GameOverView({super.key});

  String _getPerformanceMessage(double accuracy) {
    if (accuracy >= 0.9) return "Outstanding focus!";
    if (accuracy >= 0.7) return "Great job!";
    if (accuracy >= 0.5) return "Good effort!";
    return "Keep practicing to improve your focus!";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finalScore = ref.watch(scoreProvider);
    final correct = ref.watch(correctAnswersProvider);
    final total = ref.watch(totalAttemptsProvider);
    final accuracy = (total == 0) ? 0.0 : correct / total;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Game Over!', style: GoogleFonts.pressStart2p(fontSize: 36.0, color: Colors.white)),
          const SizedBox(height: 30),
          Text('Final Score: $finalScore', style: GoogleFonts.inter(fontSize: 24.0, color: Colors.white)),
          Text('Accuracy: ${(accuracy * 100).toStringAsFixed(1)}%', style: GoogleFonts.inter(fontSize: 20.0, color: Colors.white)),
          const SizedBox(height: 20),
          Text(
            _getPerformanceMessage(accuracy),
            style: GoogleFonts.inter(fontSize: 18.0, fontStyle: FontStyle.italic, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () => ref.read(gameLogicProvider).startGame(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: Text('Restart Game', style: GoogleFonts.pressStart2p(fontSize: 16.0, color: Colors.black)),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: Text(
              'Main Menu',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- UI HELPER WIDGETS ---

class DirectionalHint extends StatelessWidget {
  final Direction direction;
  const DirectionalHint({required this.direction, super.key});

  (IconData, Color) getHintStyle() {
    switch (direction) {
      case Direction.up:    return (Icons.arrow_upward, Colors.blue);
      case Direction.down:  return (Icons.arrow_downward, Colors.yellow);
      case Direction.left:  return (Icons.arrow_back, Colors.green);
      case Direction.right: return (Icons.arrow_forward, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = getHintStyle();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const InfoChip({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.pressStart2p(fontSize: 28.0, color: Colors.white)),
      ],
    );
  }
}
