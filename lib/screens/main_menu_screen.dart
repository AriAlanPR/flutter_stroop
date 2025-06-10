import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/providers/game_providers.dart';
import 'package:myapp/screens/game_screen.dart';
import 'package:myapp/screens/instructions_screen.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8BC34A), // Light Green
              Color(0xFF4CAF50), // Green
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'STROOP',
                style: GoogleFonts.inter(
                  fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 60.0 : 80.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 5.0,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              Text(
                'GAME',
                style: GoogleFonts.inter(
                  fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 30.0 : 40.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 80),

              _MenuButton(
                text: 'Start Game',
                color: const Color(0xFF2ECC71),
                onPressed: () {
                  // Reset game state providers
                  ref.read(scoreProvider.notifier).state = 0;
                  ref.read(timerProvider.notifier).state = 30;
                  ref.read(currentWordProvider.notifier).state = {};
                  ref.read(gameStateProvider.notifier).state = GameState.ready;

                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Instructions',
                color: const Color(0xFF2196F3),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const InstructionsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 20.0 : 24.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
