import 'package:flutter/material.dart';

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

  /// Returns `true` if the word name matches its ink color (congruent condition),
  /// or `false` if they conflict (incongruent condition).
  bool get isCongruent => kStroopColorMap[word] == color;

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
  final List<int> reactionTimesMs;
  final int congruentAttempts;
  final int congruentCorrect;
  final int incongruentAttempts;
  final int incongruentCorrect;

  const GameSession({
    this.gameState = GameState.ready,
    this.score = 0,
    this.timer = 30,
    this.currentChallenge,
    this.correctAnswers = 0,
    this.totalAttempts = 0,
    this.isNewHighScore = false,
    this.reactionTimesMs = const [],
    this.congruentAttempts = 0,
    this.congruentCorrect = 0,
    this.incongruentAttempts = 0,
    this.incongruentCorrect = 0,
  });

  /// Computed accuracy percentage (0.0 to 100.0).
  double get accuracy =>
      totalAttempts == 0 ? 0.0 : (correctAnswers / totalAttempts) * 100.0;

  /// Average reaction time across all trials in milliseconds.
  int get averageReactionTimeMs => reactionTimesMs.isEmpty
      ? 0
      : (reactionTimesMs.reduce((a, b) => a + b) / reactionTimesMs.length)
          .round();

  /// Best (fastest) reaction time across all trials in milliseconds.
  int get bestReactionTimeMs => reactionTimesMs.isEmpty
      ? 0
      : reactionTimesMs.reduce((a, b) => a < b ? a : b);

  /// Accuracy percentage for congruent trials.
  double get congruentAccuracy => congruentAttempts == 0
      ? 0.0
      : (congruentCorrect / congruentAttempts) * 100.0;

  /// Accuracy percentage for incongruent trials.
  double get incongruentAccuracy => incongruentAttempts == 0
      ? 0.0
      : (incongruentCorrect / incongruentAttempts) * 100.0;

  GameSession copyWith({
    GameState? gameState,
    int? score,
    int? timer,
    WordChallenge? currentChallenge,
    int? correctAnswers,
    int? totalAttempts,
    bool? isNewHighScore,
    List<int>? reactionTimesMs,
    int? congruentAttempts,
    int? congruentCorrect,
    int? incongruentAttempts,
    int? incongruentCorrect,
  }) {
    return GameSession(
      gameState: gameState ?? this.gameState,
      score: score ?? this.score,
      timer: timer ?? this.timer,
      currentChallenge: currentChallenge ?? this.currentChallenge,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      isNewHighScore: isNewHighScore ?? this.isNewHighScore,
      reactionTimesMs: reactionTimesMs ?? this.reactionTimesMs,
      congruentAttempts: congruentAttempts ?? this.congruentAttempts,
      congruentCorrect: congruentCorrect ?? this.congruentCorrect,
      incongruentAttempts: incongruentAttempts ?? this.incongruentAttempts,
      incongruentCorrect: incongruentCorrect ?? this.incongruentCorrect,
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
          isNewHighScore == other.isNewHighScore &&
          congruentAttempts == other.congruentAttempts &&
          congruentCorrect == other.congruentCorrect &&
          incongruentAttempts == other.incongruentAttempts &&
          incongruentCorrect == other.incongruentCorrect;

  @override
  int get hashCode =>
      gameState.hashCode ^
      score.hashCode ^
      timer.hashCode ^
      (currentChallenge?.hashCode ?? 0) ^
      correctAnswers.hashCode ^
      totalAttempts.hashCode ^
      isNewHighScore.hashCode ^
      congruentAttempts.hashCode ^
      congruentCorrect.hashCode ^
      incongruentAttempts.hashCode ^
      incongruentCorrect.hashCode;
}
