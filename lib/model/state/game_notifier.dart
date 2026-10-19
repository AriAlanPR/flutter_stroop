import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stroop/model/game_session.dart';

/// Mapping of color names to Color objects.
final Map<String, Color> kStroopColorMap = {
  'RED': Colors.red,
  'GREEN': Colors.green,
  'BLUE': Colors.blue,
  'YELLOW': Colors.yellow,
};

/// Mapping of ink colors to their corresponding correct input direction.
final Map<Color, Direction> kStroopColorDirectionMap = {
  Colors.red: Direction.right,
  Colors.green: Direction.left,
  Colors.blue: Direction.up,
  Colors.yellow: Direction.down,
};

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

/// Riverpod notifier managing the game session lifecycle and scoring rules.
class GameNotifier extends AutoDisposeNotifier<GameSession> {
  Timer? _gameTimer;

  @override
  GameSession build() {
    ref.onDispose(() => _cancelTimer());
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

  /// Starts or restarts a game session.
  void startGame() {
    _cancelTimer();

    final firstChallenge = _generateChallenge();

    state = state.copyWith(
      gameState: GameState.playing,
      score: 0,
      timer: 30,
      currentChallenge: firstChallenge,
      correctAnswers: 0,
      totalAttempts: 0,
    );

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timer > 1) {
        state = state.copyWith(timer: state.timer - 1);
      } else {
        _cancelTimer();
        state = state.copyWith(
          timer: 0,
          gameState: GameState.gameOver,
        );
      }
    });
  }

  /// Manually stops the current game and marks it as gameOver.
  void stopGame() {
    _cancelTimer();
    state = state.copyWith(gameState: GameState.gameOver);
  }

  /// Resets the game to ready state and clears running timers.
  void resetGame() {
    _cancelTimer();
    state = const GameSession(gameState: GameState.ready);
  }

  /// Evaluates the user's directional swipe or key press.
  void checkAnswer(Direction inputDirection) {
    if (state.gameState != GameState.playing) return;

    final challenge = state.currentChallenge;
    if (challenge == null) return;

    final correctDirection = kStroopColorDirectionMap[challenge.color];
    final isCorrect = inputDirection == correctDirection;
    final nextChallenge = _generateChallenge();

    final newAttempts = state.totalAttempts + 1;

    if (isCorrect) {
      final newScore = state.score + 1;
      final newCorrect = state.correctAnswers + 1;
      final newTimer = min(99, state.timer + 1);

      state = state.copyWith(
        score: newScore,
        correctAnswers: newCorrect,
        totalAttempts: newAttempts,
        timer: newTimer,
        currentChallenge: nextChallenge,
      );
    } else {
      final newTimer = max(0, state.timer - 2);

      if (newTimer == 0) {
        _cancelTimer();
        state = state.copyWith(
          totalAttempts: newAttempts,
          timer: 0,
          gameState: GameState.gameOver,
          currentChallenge: nextChallenge,
        );
      } else {
        state = state.copyWith(
          totalAttempts: newAttempts,
          timer: newTimer,
          currentChallenge: nextChallenge,
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
