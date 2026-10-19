import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stroop/model/state/score_providers.dart';
import 'package:stroop/screens/game_screen.dart';
import 'package:stroop/widgets/instructions_dialog.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const InstructionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highScore = ref.watch(highScoreProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Stroop Focus',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 36.0,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      blurRadius: 10.0,
                      color: Colors.black26,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'HIGH SCORE: $highScore',
                key: const Key('high_score_text'),
                style: GoogleFonts.pressStart2p(
                  fontSize: 16.0,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                key: const Key('play_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                child: Text(
                  'Play',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                key: const Key('how_to_play_button'),
                onPressed: () => _showInstructions(context),
                child: Text(
                  'How to Play',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
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
