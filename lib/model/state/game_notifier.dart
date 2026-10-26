import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stroop/model/game_session.dart';
import 'package:stroop/model/state/score_providers.dart';
import 'package:stroop/model/state/sound_providers.dart';

/// Provider for timestamp generation (allows injecting deterministic clock in tests).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Provider for custom challenge generation (allows injecting deterministic challenges in tests).
final challengeGeneratorProvider = Provider<WordChallenge Function()>((ref) {
  final random = Random();
  final words = kStroopColorMap.keys.toList();
  final colors = kStroopColorMap.values.toList();
  return () {
    final word = words[random.nextInt(words.length)];
    final color = colors[random.nextInt(colors.length)];
    return WordChallenge(word: word, color: color);
  };
});

/// Riverpod notifier managing the game session lifecycle, scoring rules and persistence.
class GameNotifier extends AutoDisposeNotifier<GameSession> {
  Timer? _gameTimer;
  DateTime? _stimulusShownAt;

  @override
  GameSession build() {
    final audio = ref.read(audioServiceProvider);
    ref.onDispose(() {
      _cancelTimer();
      audio.stopBgm();
    });
    _stimulusShownAt = null;
    return const GameSession();
  }

  void _cancelTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  WordChallenge _generateChallenge() {
    final generator = ref.read(challengeGeneratorProvider);
    return generator();
  }

  Future<void> _handleGameOver({
    int? finalScore,
    int? totalAttempts,
    WordChallenge? nextChallenge,
    List<int>? reactionTimesMs,
    int? congruentAttempts,
    int? congruentCorrect,
    int? incongruentAttempts,
    int? incongruentCorrect,
  }) async {
    _cancelTimer();
    _stimulusShownAt = null;
    final scoreToRecord = finalScore ?? state.score;

    final audio = ref.read(audioServiceProvider);
    audio.stopBgm();
    audio.playGameOver();

    state = state.copyWith(
      score: scoreToRecord,
      totalAttempts: totalAttempts ?? state.totalAttempts,
      currentChallenge: nextChallenge ?? state.currentChallenge,
      timer: 0,
      gameState: GameState.gameOver,
      reactionTimesMs: reactionTimesMs ?? state.reactionTimesMs,
      congruentAttempts: congruentAttempts ?? state.congruentAttempts,
      congruentCorrect: congruentCorrect ?? state.congruentCorrect,
      incongruentAttempts: incongruentAttempts ?? state.incongruentAttempts,
      incongruentCorrect: incongruentCorrect ?? state.incongruentCorrect,
    );

    final storage = ref.read(storageServiceProvider);
    if (storage != null) {
      final isNewRecord = await storage.recordGamePlayed(scoreToRecord);
      ref.read(highScoreProvider.notifier).refresh();
      state = state.copyWith(isNewHighScore: isNewRecord);
    }
  }

  /// Starts or restarts a game session.
  void startGame() {
    _cancelTimer();
    ref.read(audioServiceProvider).startBgm();

    final firstChallenge = _generateChallenge();
    _stimulusShownAt = ref.read(clockProvider)();

    state = state.copyWith(
      gameState: GameState.playing,
      score: 0,
      timer: 30,
      currentChallenge: firstChallenge,
      correctAnswers: 0,
      totalAttempts: 0,
      isNewHighScore: false,
      reactionTimesMs: const [],
      congruentAttempts: 0,
      congruentCorrect: 0,
      incongruentAttempts: 0,
      incongruentCorrect: 0,
    );

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timer > 1) {
        final remaining = state.timer - 1;
        if (remaining <= 3) {
          ref.read(audioServiceProvider).playWarningTick();
        }
        state = state.copyWith(timer: remaining);
      } else {
        _handleGameOver();
      }
    });
  }

  /// Manually stops the current game and marks it as gameOver.
  Future<void> stopGame() async {
    await _handleGameOver();
  }

  /// Resets the game to ready state and clears running timers.
  void resetGame() {
    _cancelTimer();
    ref.read(audioServiceProvider).stopBgm();
    _stimulusShownAt = null;
    state = const GameSession(gameState: GameState.ready);
  }

  /// Evaluates the user's directional swipe or key press.
  void checkAnswer(Direction inputDirection) {
    if (state.gameState != GameState.playing) return;

    final challenge = state.currentChallenge;
    if (challenge == null) return;

    final clock = ref.read(clockProvider);
    final now = clock();
    final elapsedMs = _stimulusShownAt != null
        ? now.difference(_stimulusShownAt!).inMilliseconds
        : 0;
    final updatedReactionTimes = [...state.reactionTimesMs, elapsedMs];

    final isCongruent = challenge.isCongruent;
    final correctDirection = kStroopColorDirectionMap[challenge.color];
    final isCorrect = inputDirection == correctDirection;
    final nextChallenge = _generateChallenge();
    _stimulusShownAt = now;

    final newAttempts = state.totalAttempts + 1;
    final newCongruentAttempts =
        state.congruentAttempts + (isCongruent ? 1 : 0);
    final newCongruentCorrect =
        state.congruentCorrect + (isCongruent && isCorrect ? 1 : 0);
    final newIncongruentAttempts =
        state.incongruentAttempts + (!isCongruent ? 1 : 0);
    final newIncongruentCorrect =
        state.incongruentCorrect + (!isCongruent && isCorrect ? 1 : 0);

    if (isCorrect) {
      ref.read(audioServiceProvider).playCorrect();
      final newScore = state.score + 1;
      final newCorrect = state.correctAnswers + 1;
      final newTimer = min(99, state.timer + 1);

      state = state.copyWith(
        score: newScore,
        correctAnswers: newCorrect,
        totalAttempts: newAttempts,
        timer: newTimer,
        currentChallenge: nextChallenge,
        reactionTimesMs: updatedReactionTimes,
        congruentAttempts: newCongruentAttempts,
        congruentCorrect: newCongruentCorrect,
        incongruentAttempts: newIncongruentAttempts,
        incongruentCorrect: newIncongruentCorrect,
      );
    } else {
      ref.read(audioServiceProvider).playIncorrect();
      final newTimer = max(0, state.timer - 2);

      if (newTimer == 0) {
        _handleGameOver(
          totalAttempts: newAttempts,
          nextChallenge: nextChallenge,
          reactionTimesMs: updatedReactionTimes,
          congruentAttempts: newCongruentAttempts,
          congruentCorrect: newCongruentCorrect,
          incongruentAttempts: newIncongruentAttempts,
          incongruentCorrect: newIncongruentCorrect,
        );
      } else {
        state = state.copyWith(
          totalAttempts: newAttempts,
          timer: newTimer,
          currentChallenge: nextChallenge,
          reactionTimesMs: updatedReactionTimes,
          congruentAttempts: newCongruentAttempts,
          congruentCorrect: newCongruentCorrect,
          incongruentAttempts: newIncongruentAttempts,
          incongruentCorrect: newIncongruentCorrect,
        );
      }
    }
  }

  /// Visible for testing to check if the timer is currently running.
  @visibleForTesting
  bool get isTimerRunning => _gameTimer != null && _gameTimer!.isActive;
}

/// Provider for GameNotifier.
final gameNotifierProvider =
    NotifierProvider.autoDispose<GameNotifier, GameSession>(GameNotifier.new);
