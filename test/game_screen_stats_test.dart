import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stroop/model/game_session.dart';
import 'package:stroop/model/state/game_notifier.dart';
import 'package:stroop/model/state/score_providers.dart';
import 'package:stroop/screens/game_screen.dart';

void main() {
  group('Requirement: Post Game Cognitive Statistics Summary', () {
    testWidgets('Game over screen displays average reaction time',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      var currentTime = DateTime(2026, 1, 1, 12, 0, 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            challengeGeneratorProvider.overrideWithValue(
              () => const WordChallenge(word: 'RED', color: Colors.red),
            ),
            clockProvider.overrideWithValue(() => currentTime),
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

      // Advance by 300ms and answer
      currentTime = currentTime.add(const Duration(milliseconds: 300));
      notifier.checkAnswer(Direction.right);

      // Advance by 400ms and answer
      currentTime = currentTime.add(const Duration(milliseconds: 400));
      notifier.checkAnswer(Direction.right);

      await notifier.stopGame();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('avg_reaction_time_chip')), findsOneWidget);
      expect(find.text('Avg Time: 350ms'), findsOneWidget);
    });

    testWidgets(
        'Game over screen displays cognitive congruency accuracy breakdown',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      int callCount = 0;
      final challenges = [
        // 1st challenge: congruent (RED / red)
        const WordChallenge(word: 'RED', color: Colors.red),
        // 2nd challenge: incongruent (BLUE / red)
        const WordChallenge(word: 'BLUE', color: Colors.red),
        // fallback
        const WordChallenge(word: 'RED', color: Colors.red),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            challengeGeneratorProvider.overrideWithValue(
              () => challenges[(callCount++) % challenges.length],
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

      // Trial 1: congruent (RED / red) -> correct answer is Direction.right (100% congruent)
      notifier.checkAnswer(Direction.right);

      // Trial 2: incongruent (BLUE / red) -> wrong answer Direction.up (0% incongruent)
      notifier.checkAnswer(Direction.up);

      await notifier.stopGame();
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('congruency_breakdown_chip')), findsOneWidget);
      expect(find.text('Congruent: 100.0%'), findsOneWidget);
      expect(find.text('Incongruent: 0.0%'), findsOneWidget);
    });
  });
}
