import 'package:flutter/material.dart';

/// Represents the overall state of the game session.
enum GameState {
  ready,
  playing,
  gameOver,
}

/// Represents the directional input options.
enum Direction {
  up,
  down,
  left,
  right,
}

/// Represents a Stroop stimulus challenge with a word and an ink color.
class WordChallenge {
  final String word;
  final Color color;

  const WordChallenge({
    required this.word,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordChallenge &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          color == other.color;

  @override
  int get hashCode => word.hashCode ^ color.hashCode;
}

/// Immutable data model holding the full state of a game session.
class GameSession {
  final GameState gameState;
  final int score;
  final int timer;
  final WordChallenge? currentChallenge;
  final int correctAnswers;
  final int totalAttempts;
  final bool isNewHighScore;

  const GameSession({
    this.gameState = GameState.ready,
    this.score = 0,
    this.timer = 30,
    this.currentChallenge,
    this.correctAnswers = 0,
    this.totalAttempts = 0,
    this.isNewHighScore = false,
  });

  /// Computed accuracy percentage (0.0 to 100.0).
  double get accuracy =>
      totalAttempts == 0 ? 0.0 : (correctAnswers / totalAttempts) * 100.0;

  GameSession copyWith({
    GameState? gameState,
    int? score,
    int? timer,
    WordChallenge? currentChallenge,
    int? correctAnswers,
    int? totalAttempts,
    bool? isNewHighScore,
  }) {
    return GameSession(
      gameState: gameState ?? this.gameState,
      score: score ?? this.score,
      timer: timer ?? this.timer,
      currentChallenge: currentChallenge ?? this.currentChallenge,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      isNewHighScore: isNewHighScore ?? this.isNewHighScore,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSession &&
          runtimeType == other.runtimeType &&
          gameState == other.gameState &&
          score == other.score &&
          timer == other.timer &&
          currentChallenge == other.currentChallenge &&
          correctAnswers == other.correctAnswers &&
          totalAttempts == other.totalAttempts &&
          isNewHighScore == other.isNewHighScore;

  @override
  int get hashCode =>
      gameState.hashCode ^
      score.hashCode ^
      timer.hashCode ^
      (currentChallenge?.hashCode ?? 0) ^
      correctAnswers.hashCode ^
      totalAttempts.hashCode ^
      isNewHighScore.hashCode;
}
