import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stroop/model/state/score_providers.dart';
import 'package:stroop/screens/game_screen.dart';
import 'package:stroop/widgets/instructions_dialog.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highScore = ref.watch(highScoreProvider);
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
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
                  color: onPrimary,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: theme.shadowColor.withValues(alpha: 0.3),
                      offset: const Offset(5.0, 5.0),
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
                  color: onPrimary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                key: const Key('play_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
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
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                key: const Key('how_to_play_button'),
                onPressed: () => InstructionsDialog.show(context),
                child: Text(
                  'How to Play',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: onPrimary,
                    decoration: TextDecoration.underline,
                    decorationColor: onPrimary,
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
