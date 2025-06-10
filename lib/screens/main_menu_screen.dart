import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/providers/game_providers.dart';
import 'package:myapp/screens/game_screen.dart';
import 'package:myapp/screens/instructions_screen.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
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
                  fontSize: 80.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 5.0,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              Text(
                'GAME',
                style: GoogleFonts.inter(
                  fontSize: 40.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 80),

              ElevatedButton(
                onPressed: () {
                  // Reset game state providers
                  ref.read(scoreProvider.notifier).state = 0;
                  ref.read(timerProvider.notifier).state = 30;
                  ref.read(currentWordProvider.notifier).state = {};
                  ref.read(gameStateProvider.notifier).state = GameState.ready;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GameScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71), // Emerald green
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Start Game',
                  style: GoogleFonts.inter(
                    fontSize: 24.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const InstructionsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3), // Primary color
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Instructions',
                  style: GoogleFonts.inter(
                    fontSize: 24.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
