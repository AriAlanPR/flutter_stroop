import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for local persistence of game scores and play history.
class StorageService {
  static const String keyHighScore = 'stroop_high_score';
  static const String keyTotalGames = 'stroop_total_games';

  final SharedPreferences _prefs;

  const StorageService(this._prefs);

  /// Retrieves the persisted high score (defaults to 0).
  int getHighScore() {
    return _prefs.getInt(keyHighScore) ?? 0;
  }

  /// Saves a new high score if [score] exceeds the existing record.
  /// Returns `true` if a new high score was recorded, `false` otherwise.
  Future<bool> saveHighScore(int score) async {
    final current = getHighScore();
    if (score > current) {
      await _prefs.setInt(keyHighScore, score);
      return true;
    }
    return false;
  }

  /// Retrieves total games played count (defaults to 0).
  int getTotalGamesPlayed() {
    return _prefs.getInt(keyTotalGames) ?? 0;
  }

  /// Records the conclusion of a game session, incrementing the games played
  /// counter and updating the high score if applicable.
  /// Returns `true` if this game resulted in a new high score.
  Future<bool> recordGamePlayed(int finalScore) async {
    final currentGames = getTotalGamesPlayed();
    await _prefs.setInt(keyTotalGames, currentGames + 1);
    final isNewRecord = await saveHighScore(finalScore);
    return isNewRecord;
  }
}
