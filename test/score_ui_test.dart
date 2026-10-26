import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stroop/model/game_session.dart';
import 'package:stroop/model/services/storage_service.dart';
import 'package:stroop/model/state/game_notifier.dart';
import 'package:stroop/model/state/score_providers.dart';
import 'package:stroop/screens/game_screen.dart';
import 'package:stroop/screens/main_menu_screen.dart';

void main() {
  group('score-persistence UI tests', () {
    testWidgets('Main menu displays current high score',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        StorageService.keyHighScore: 25,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: MainMenuScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('high_score_text')), findsOneWidget);
      expect(find.text('HIGH SCORE: 25'), findsOneWidget);
    });

    testWidgets('Game over screen indicates new high score achieved',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        StorageService.keyHighScore: 10,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            challengeGeneratorProvider.overrideWithValue(
              () => const WordChallenge(word: 'RED', color: Colors.blue),
            ),
          ],
          child: const MaterialApp(
            home: GameScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(GameScreen));
      final container = ProviderScope.containerOf(element);
      final notifier = container.read(gameNotifierProvider.notifier);

      // Score 18 points (Colors.blue -> Direction.up)
      for (int i = 0; i < 18; i++) {
        notifier.checkAnswer(Direction.up);
      }

      await notifier.stopGame();
      await tester.pumpAndSettle();

      expect(find.text('Game Over!'), findsOneWidget);
      expect(find.text('Final Score: 18'), findsOneWidget);
      expect(find.byKey(const Key('new_high_score_banner')), findsOneWidget);
      expect(find.text('NEW HIGH SCORE!'), findsOneWidget);
    });
  });
}
