import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Service responsible for triggering audio sound effects and device haptics.
class AudioService {
  final AudioPlayer _player;
  final bool Function() _isSoundEnabled;

  AudioService({
    AudioPlayer? player,
    bool Function()? isSoundEnabled,
  })  : _player = player ?? AudioPlayer(),
        _isSoundEnabled = isSoundEnabled ?? (() => true) {
    _initPlayer();
  }

  void _initPlayer() {
    try {
      _player.setPlayerMode(PlayerMode.lowLatency);
    } catch (_) {
      // Ignore if lowLatency mode is not supported on the target platform
    }
  }

  /// Plays the positive confirmation sound and emits light haptic feedback.
  Future<void> playCorrect() async {
    if (!_isSoundEnabled()) return;
    try {
      await HapticFeedback.lightImpact();
      await _player.stop();
      await _player.play(AssetSource('audio/correct.wav'));
    } catch (_) {
      // Fail-soft: audio playback failure must never disrupt gameplay
    }
  }

  /// Plays the error buzzer sound and emits medium haptic feedback.
  Future<void> playIncorrect() async {
    if (!_isSoundEnabled()) return;
    try {
      await HapticFeedback.mediumImpact();
      await _player.stop();
      await _player.play(AssetSource('audio/incorrect.wav'));
    } catch (_) {
      // Fail-soft
    }
  }

  /// Plays the game over jingle and emits heavy haptic feedback.
  Future<void> playGameOver() async {
    if (!_isSoundEnabled()) return;
    try {
      await HapticFeedback.heavyImpact();
      await _player.stop();
      await _player.play(AssetSource('audio/game_over.wav'));
    } catch (_) {
      // Fail-soft
    }
  }

  /// Plays a short warning tick click without haptic feedback.
  Future<void> playWarningTick() async {
    if (!_isSoundEnabled()) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/tick.wav'));
    } catch (_) {
      // Fail-soft
    }
  }

  /// Releases audio resources when disposed.
  void dispose() {
    try {
      _player.dispose();
    } catch (_) {
      // Ignore cleanup errors
    }
  }
}
