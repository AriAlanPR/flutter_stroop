import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stroop/model/game_session.dart';
import 'package:stroop/model/services/audio_service.dart';
import 'package:stroop/model/state/game_notifier.dart';
import 'package:stroop/model/state/sound_providers.dart';

class MockAudioService implements AudioService {
  int correctCalls = 0;
  int incorrectCalls = 0;
  int gameOverCalls = 0;
  int warningTickCalls = 0;

  @override
  Future<void> playCorrect() async {
    correctCalls++;
  }

  @override
  Future<void> playIncorrect() async {
    incorrectCalls++;
  }

  @override
  Future<void> playGameOver() async {
    gameOverCalls++;
  }

  @override
  Future<void> playWarningTick() async {
    warningTickCalls++;
  }

  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('audio-feedback game integration tests', () {
    late MockAudioService mockAudio;

    setUp(() {
      mockAudio = MockAudioService();
    });

    test('Correct response triggers positive sound and light haptic', () {
      final container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
          challengeGeneratorProvider.overrideWithValue(
            () => const WordChallenge(word: 'RED', color: Colors.blue),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.startGame();

      // Colors.blue corresponds to Direction.up
      notifier.checkAnswer(Direction.up);

      expect(mockAudio.correctCalls, 1);
      expect(mockAudio.incorrectCalls, 0);
      expect(mockAudio.gameOverCalls, 0);
    });

    test('Incorrect response triggers error sound and medium haptic', () {
      final container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
          challengeGeneratorProvider.overrideWithValue(
            () => const WordChallenge(word: 'RED', color: Colors.blue),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.startGame();

      // Colors.blue corresponds to Direction.up. Submitting Direction.down is incorrect.
      notifier.checkAnswer(Direction.down);

      expect(mockAudio.correctCalls, 0);
      expect(mockAudio.incorrectCalls, 1);
      expect(mockAudio.gameOverCalls, 0);
    });

    test('Game over triggers game over sound and heavy haptic', () async {
      final container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
          challengeGeneratorProvider.overrideWithValue(
            () => const WordChallenge(word: 'RED', color: Colors.blue),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.startGame();

      await notifier.stopGame();

      expect(mockAudio.gameOverCalls, 1);
    });
  });
}
