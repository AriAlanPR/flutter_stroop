import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Contract for audio and haptic feedback triggers.
abstract class AudioService {
  Future<void> playCorrect();
  Future<void> playIncorrect();
  Future<void> playGameOver();
  Future<void> playWarningTick();
  void dispose();
}

/// Default implementation utilizing audioplayers and system haptics.
class DefaultAudioService implements AudioService {
  AudioPlayer? _player;
  final bool Function() _isSoundEnabled;

  DefaultAudioService({
    AudioPlayer? player,
    bool Function()? isSoundEnabled,
  })  : _player = player,
        _isSoundEnabled = isSoundEnabled ?? (() => true);

  bool get _areBindingsInitialized {
    try {
      WidgetsBinding.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  AudioPlayer? get _safePlayer {
    if (_player != null) return _player;
    if (!_areBindingsInitialized) {
      return null;
    }
    try {
      final p = AudioPlayer();
      try {
        p.setPlayerMode(PlayerMode.lowLatency);
        // Ensure standard 'assets/' prefix
        p.audioCache.prefix = 'assets/';
      } catch (_) {}

      // Configure global audio context for mobile platforms so audio is audible
      // even if the hardware ringer/silent switch is muted on iOS.
      try {
        AudioPlayer.global.setAudioContext(
          AudioContext(
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
              options: {
                AVAudioSessionOptions.mixWithOthers,
              },
            ),
            android: const AudioContextAndroid(
              isSpeakerphoneOn: true,
              stayAwake: true,
              contentType: AndroidContentType.sonification,
              usageType: AndroidUsageType.game,
              audioFocus: AndroidAudioFocus.none,
            ),
          ),
        );
      } catch (_) {}

      return _player = p;
    } catch (e) {
      debugPrint('Error initializing AudioPlayer: $e');
      return null;
    }
  }

  Future<void> _safeHaptic(Future<void> Function() hapticAction) async {
    if (!_areBindingsInitialized) return;
    try {
      await hapticAction();
    } catch (_) {}
  }

  @override
  Future<void> playCorrect() async {
    if (!_isSoundEnabled()) return;
    await _safeHaptic(HapticFeedback.lightImpact);
    try {
      final player = _safePlayer;
      await player?.stop();
      await player?.play(AssetSource('audio/correct.wav'));
    } catch (e) {
      debugPrint('Error playing correct audio: $e');
    }
  }

  @override
  Future<void> playIncorrect() async {
    if (!_isSoundEnabled()) return;
    await _safeHaptic(HapticFeedback.mediumImpact);
    try {
      final player = _safePlayer;
      await player?.stop();
      await player?.play(AssetSource('audio/incorrect.wav'));
    } catch (e) {
      debugPrint('Error playing incorrect audio: $e');
    }
  }

  @override
  Future<void> playGameOver() async {
    if (!_isSoundEnabled()) return;
    await _safeHaptic(HapticFeedback.heavyImpact);
    try {
      final player = _safePlayer;
      await player?.stop();
      await player?.play(AssetSource('audio/game_over.wav'));
    } catch (e) {
      debugPrint('Error playing game over audio: $e');
    }
  }

  @override
  Future<void> playWarningTick() async {
    if (!_isSoundEnabled()) return;
    try {
      final player = _safePlayer;
      await player?.stop();
      await player?.play(AssetSource('audio/tick.wav'));
    } catch (e) {
      debugPrint('Error playing warning tick audio: $e');
    }
  }

  @override
  void dispose() {
    try {
      _player?.dispose();
    } catch (_) {
      // Fail-soft
    }
  }
}
