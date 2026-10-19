import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stroop/model/game_session.dart';
import 'package:stroop/model/state/game_notifier.dart';
import 'package:stroop/screens/main_menu_screen.dart';
import 'package:stroop/widgets/instructions_dialog.dart';

/// Main entry point for the game screen.
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
      ref.read(gameNotifierProvider.notifier).startGame();
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
    final gameSession = ref.watch(gameNotifierProvider);

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
          title: Text(
            'Stroop Focus',
            style: GoogleFonts.pressStart2p(color: Colors.white),
          ),
          actions: [
            IconButton(
              key: const Key('help_button'),
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () => _showInstructions(context),
            ),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanEnd: (details) => _handleSwipe(details, ref),
          child: _buildGameStateView(gameSession.gameState),
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
        return const Center(child: CircularProgressIndicator());
    }
  }

  // --- INPUT HANDLERS ---

  void _handleKeyPress(LogicalKeyboardKey key, WidgetRef ref) {
    final notifier = ref.read(gameNotifierProvider.notifier);
    if (key == LogicalKeyboardKey.arrowUp) {
      notifier.checkAnswer(Direction.up);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      notifier.checkAnswer(Direction.down);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      notifier.checkAnswer(Direction.left);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      notifier.checkAnswer(Direction.right);
    }
  }

  void _handleSwipe(DragEndDetails details, WidgetRef ref) {
    final velocity = details.velocity.pixelsPerSecond;
    final notifier = ref.read(gameNotifierProvider.notifier);

    if (velocity.distanceSquared > (_minSwipeVelocity * _minSwipeVelocity)) {
      if (velocity.dx.abs() > velocity.dy.abs()) {
        if (velocity.dx < 0) {
          notifier.checkAnswer(Direction.left);
        } else {
          notifier.checkAnswer(Direction.right);
        }
      } else {
        if (velocity.dy < 0) {
          notifier.checkAnswer(Direction.up);
        } else {
          notifier.checkAnswer(Direction.down);
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
    final session = ref.watch(gameNotifierProvider);
    final challenge = session.currentChallenge;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InfoChip(label: 'Score', value: session.score.toString()),
              InfoChip(label: 'Time', value: session.timer.toString()),
            ],
          ),
        ),
        const Spacer(),
        if (challenge != null)
          Text(
            challenge.word,
            key: const Key('challenge_word'),
            style: GoogleFonts.pressStart2p(
              fontSize: 48.0,
              color: challenge.color,
            ),
          ),
        const Spacer(),
      ],
    );
  }
}

class GameOverView extends ConsumerWidget {
  const GameOverView({super.key});

  String _getPerformanceMessage(double accuracy) {
    if (accuracy >= 90.0) return "Outstanding focus!";
    if (accuracy >= 70.0) return "Great job!";
    if (accuracy >= 50.0) return "Good effort!";
    return "Keep practicing to improve your focus!";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameNotifierProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Game Over!',
            style: GoogleFonts.pressStart2p(fontSize: 36.0, color: Colors.white),
          ),
          const SizedBox(height: 30),
          Text(
            'Final Score: ${session.score}',
            style: GoogleFonts.inter(fontSize: 24.0, color: Colors.white),
          ),
          Text(
            'Accuracy: ${session.accuracy.toStringAsFixed(1)}%',
            style: GoogleFonts.inter(fontSize: 20.0, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            _getPerformanceMessage(session.accuracy),
            style: GoogleFonts.inter(
              fontSize: 18.0,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            key: const Key('restart_game_button'),
            onPressed: () =>
                ref.read(gameNotifierProvider.notifier).startGame(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: Text(
              'Restart Game',
              style: GoogleFonts.pressStart2p(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            key: const Key('main_menu_button'),
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
                decorationColor: Colors.white,
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
      case Direction.up:
        return (Icons.arrow_upward, Colors.blue);
      case Direction.down:
        return (Icons.arrow_downward, Colors.yellow);
      case Direction.left:
        return (Icons.arrow_back, Colors.green);
      case Direction.right:
        return (Icons.arrow_forward, Colors.red);
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
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.pressStart2p(fontSize: 28.0, color: Colors.white),
        ),
      ],
    );
  }
}
