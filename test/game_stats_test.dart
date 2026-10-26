import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stroop/model/game_session.dart';
import 'package:stroop/model/state/game_notifier.dart';

void main() {
  group('Requirement: Stimulus Congruency and Reaction Time Tracking', () {
    test('Congruent stimulus matching word and ink color is identified', () {
      final challenge =
          const WordChallenge(word: 'RED', color: Colors.red);
      expect(challenge.isCongruent, isTrue);

      final container = ProviderContainer(
        overrides: [
          challengeGeneratorProvider.overrideWithValue(() => challenge),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.startGame();

      // RED with red color corresponds to Direction.right
      notifier.checkAnswer(Direction.right);

      final session = container.read(gameNotifierProvider);
      expect(session.congruentAttempts, 1);
      expect(session.congruentCorrect, 1);
      expect(session.incongruentAttempts, 0);
      expect(session.incongruentCorrect, 0);
      expect(session.congruentAccuracy, 100.0);
    });

    test(
        'Incongruent stimulus with conflicting word and ink color is identified',
        () {
      final challenge =
          const WordChallenge(word: 'BLUE', color: Colors.red);
      expect(challenge.isCongruent, isFalse);

      final container = ProviderContainer(
        overrides: [
          challengeGeneratorProvider.overrideWithValue(() => challenge),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.startGame();

      // Submit an answer (even wrong direction, e.g. Direction.up)
      notifier.checkAnswer(Direction.up);

      final session = container.read(gameNotifierProvider);
      expect(session.incongruentAttempts, 1);
      expect(session.incongruentCorrect, 0);
      expect(session.congruentAttempts, 0);
      expect(session.congruentCorrect, 0);
      expect(session.incongruentAccuracy, 0.0);
    });

    test('Player response records reaction time in milliseconds', () {
      var currentTime = DateTime(2026, 1, 1, 12, 0, 0);

      final container = ProviderContainer(
        overrides: [
          challengeGeneratorProvider.overrideWithValue(
            () => const WordChallenge(word: 'RED', color: Colors.red),
          ),
          clockProvider.overrideWithValue(() => currentTime),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.startGame();

      // Advance clock by 350 ms
      currentTime = currentTime.add(const Duration(milliseconds: 350));
      notifier.checkAnswer(Direction.right);

      final session = container.read(gameNotifierProvider);
      expect(session.reactionTimesMs, [350]);
      expect(session.averageReactionTimeMs, 350);
      expect(session.bestReactionTimeMs, 350);
    });
  });
}
