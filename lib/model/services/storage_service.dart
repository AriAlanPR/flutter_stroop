import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for local persistence of game scores and play history.
class StorageService {
  static const String keyHighScore = 'stroop_high_score';
  static const String keyTotalGames = 'stroop_total_games';
  static const String keySoundEnabled = 'stroop_sound_enabled';
  static const String keyBgmEnabled = 'stroop_bgm_enabled';
  static const String keySfxVolume = 'stroop_sfx_volume';
  static const String keyBgmVolume = 'stroop_bgm_volume';
  static const String keyHapticsEnabled = 'stroop_haptics_enabled';

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

  /// Retrieves whether audio feedback is enabled (defaults to true).
  bool isSoundEnabled() {
    return _prefs.getBool(keySoundEnabled) ?? true;
  }

  /// Persists the user preference for audio feedback.
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(keySoundEnabled, enabled);
  }

  /// Retrieves whether background music is enabled (defaults to true).
  bool isBgmEnabled() {
    return _prefs.getBool(keyBgmEnabled) ?? true;
  }

  /// Persists the user preference for background music.
  Future<void> setBgmEnabled(bool enabled) async {
    await _prefs.setBool(keyBgmEnabled, enabled);
  }

  /// Retrieves the sound effects volume (0.0 to 1.0, defaults to 1.0).
  double getSfxVolume() {
    return _prefs.getDouble(keySfxVolume) ?? 1.0;
  }

  /// Persists the sound effects volume.
  Future<void> setSfxVolume(double volume) async {
    await _prefs.setDouble(keySfxVolume, volume.clamp(0.0, 1.0));
  }

  /// Retrieves the background music volume (0.0 to 1.0, defaults to 0.6).
  double getBgmVolume() {
    return _prefs.getDouble(keyBgmVolume) ?? 0.6;
  }

  /// Persists the background music volume.
  Future<void> setBgmVolume(double volume) async {
    await _prefs.setDouble(keyBgmVolume, volume.clamp(0.0, 1.0));
  }

  /// Retrieves whether device haptic feedback is enabled (defaults to true).
  bool isHapticsEnabled() {
    return _prefs.getBool(keyHapticsEnabled) ?? true;
  }

  /// Persists the user preference for haptic feedback.
  Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs.setBool(keyHapticsEnabled, enabled);
  }
}
