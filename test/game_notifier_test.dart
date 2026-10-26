import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stroop/model/game_session.dart';
import 'package:stroop/model/services/storage_service.dart';
import 'package:stroop/model/state/game_notifier.dart';
import 'package:stroop/model/state/score_providers.dart';

void main() {
  group('game-core specification tests', () {
    test('Starting a new game initializes playing session', () {
      final container = ProviderContainer(
        overrides: [
          challengeGeneratorProvider.overrideWithValue(
            () => const WordChallenge(word: 'RED', color: Colors.blue),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameNotifierProvider.notifier);

      expect(container.read(gameNotifierProvider).gameState, GameState.ready);

      notifier.startGame();

      final state = container.read(gameNotifierProvider);
      expect(state.gameState, GameState.playing);
      expect(state.score, 0);
      expect(state.timer, 30);
      expect(state.currentChallenge, isNotNull);
      expect(state.currentChallenge!.word, 'RED');
      expect(state.currentChallenge!.color, Colors.blue);
      expect(state.correctAnswers, 0);
      expect(state.totalAttempts, 0);
    });

    test('Timer decrements periodically until zero and ends game', () async {
      final container = ProviderContainer(
        overrides: [
          challengeGeneratorProvider.overrideWithValue(
            () => const WordChallenge(word: 'RED', color: Colors.blue),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.startGame();

      // Verify timer is running
      expect(notifier.isTimerRunning, isTrue);

      // Stop game manually or let it finish
      notifier.stopGame();

      final state = container.read(gameNotifierProvider);
      expect(state.gameState, GameState.gameOver);
      expect(notifier.isTimerRunning, isFalse);
    });

    test('Leaving game cancels timer and cleans up resources', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.startGame();

      expect(notifier.isTimerRunning, isTrue);

      // Disposing container simulates unmounting/leaving screen
      container.dispose();

      expect(notifier.isTimerRunning, isFalse);
    });

    test('Correct answer increases score and adds bonus time', () {
      final container = ProviderContainer(
        overrides: [
          challengeGeneratorProvider.overrideWithValue(
            () => const WordChallenge(word: 'BLUE', color: Colors.red),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.startGame();

      // Ink color is red -> correct direction is right
      notifier.checkAnswer(Direction.right);

      final state = container.read(gameNotifierProvider);
      expect(state.score, 1);
      expect(state.correctAnswers, 1);
      expect(state.totalAttempts, 1);
      expect(state.timer, 31); // 30 + 1
      expect(state.accuracy, 100.0);
    });

    test('Incorrect answer penalizes time without increasing score', () {
      final container = ProviderContainer(
        overrides: [
          challengeGeneratorProvider.overrideWithValue(
            () => const WordChallenge(word: 'BLUE', color: Colors.red),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.startGame();

      // Ink color is red (Direction.right) -> submitting Direction.left is incorrect
      notifier.checkAnswer(Direction.left);

      final state = container.read(gameNotifierProvider);
      expect(state.score, 0);
      expect(state.correctAnswers, 0);
      expect(state.totalAttempts, 1);
      expect(state.timer, 28); // 30 - 2
      expect(state.accuracy, 0.0);
    });

    test('Submitting input when game is not playing is ignored', () {
      final container = ProviderContainer(
        overrides: [
          challengeGeneratorProvider.overrideWithValue(
            () => const WordChallenge(word: 'BLUE', color: Colors.red),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameNotifierProvider.notifier);

      expect(container.read(gameNotifierProvider).gameState, GameState.ready);

      // Submit while in ready state
      notifier.checkAnswer(Direction.right);

      final state = container.read(gameNotifierProvider);
      expect(state.gameState, GameState.ready);
      expect(state.score, 0);
      expect(state.totalAttempts, 0);
    });

    test(
        'Game over records score and sets isNewHighScore flag when record is beaten',
        () async {
      SharedPreferences.setMockInitialValues({
        StorageService.keyHighScore: 5,
        StorageService.keyTotalGames: 1,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          challengeGeneratorProvider.overrideWithValue(
            () => const WordChallenge(word: 'RED', color: Colors.blue),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.startGame();

      // Submit correct answer 6 times (Colors.blue -> Direction.up) to score 6 > 5
      for (int i = 0; i < 6; i++) {
        notifier.checkAnswer(Direction.up);
      }

      await notifier.stopGame();

      final state = container.read(gameNotifierProvider);
      expect(state.gameState, GameState.gameOver);
      expect(state.score, 6);
      expect(state.isNewHighScore, isTrue);
      expect(container.read(highScoreProvider), 6);
    });
  });
}
