import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Contract for audio and haptic feedback triggers.
abstract class AudioService {
  Future<void> playCorrect();
  Future<void> playIncorrect();
  Future<void> playGameOver();
  Future<void> playWarningTick();
  Future<void> startBgm();
  Future<void> stopBgm();
  Future<void> setSfxVolume(double volume);
  Future<void> setBgmVolume(double volume);
  void dispose();
}

/// Default implementation utilizing audioplayers and system haptics.
class DefaultAudioService implements AudioService {
  AudioPlayer? _sfxPlayer;
  AudioPlayer? _bgmPlayer;
  final bool Function() _isSoundEnabled;
  final bool Function() _isBgmEnabled;
  final bool Function() _isHapticsEnabled;
  final double Function() _getSfxVolume;
  final double Function() _getBgmVolume;

  DefaultAudioService({
    AudioPlayer? sfxPlayer,
    AudioPlayer? bgmPlayer,
    bool Function()? isSoundEnabled,
    bool Function()? isBgmEnabled,
    bool Function()? isHapticsEnabled,
    double Function()? getSfxVolume,
    double Function()? getBgmVolume,
  })  : _sfxPlayer = sfxPlayer,
        _bgmPlayer = bgmPlayer,
        _isSoundEnabled = isSoundEnabled ?? (() => true),
        _isBgmEnabled = isBgmEnabled ?? (() => true),
        _isHapticsEnabled = isHapticsEnabled ?? (() => true),
        _getSfxVolume = getSfxVolume ?? (() => 1.0),
        _getBgmVolume = getBgmVolume ?? (() => 0.6);

  bool get _areBindingsInitialized {
    try {
      WidgetsBinding.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  void _configureGlobalContext() {
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
  }

  AudioPlayer? get _safeSfxPlayer {
    if (_sfxPlayer != null) return _sfxPlayer;
    if (!_areBindingsInitialized) return null;
    try {
      final p = AudioPlayer();
      try {
        p.setPlayerMode(PlayerMode.lowLatency);
        p.audioCache.prefix = 'assets/';
      } catch (_) {}
      _configureGlobalContext();
      return _sfxPlayer = p;
    } catch (e) {
      debugPrint('Error initializing SFX AudioPlayer: $e');
      return null;
    }
  }

  AudioPlayer? get _safeBgmPlayer {
    if (_bgmPlayer != null) return _bgmPlayer;
    if (!_areBindingsInitialized) return null;
    try {
      final p = AudioPlayer();
      try {
        p.setReleaseMode(ReleaseMode.loop);
        p.audioCache.prefix = 'assets/';
      } catch (_) {}
      _configureGlobalContext();
      return _bgmPlayer = p;
    } catch (e) {
      debugPrint('Error initializing BGM AudioPlayer: $e');
      return null;
    }
  }

  Future<void> _safeHaptic(Future<void> Function() hapticAction) async {
    if (!_areBindingsInitialized || !_isHapticsEnabled()) return;
    try {
      await hapticAction();
    } catch (_) {}
  }

  @override
  Future<void> playCorrect() async {
    if (!_isSoundEnabled()) return;
    await _safeHaptic(HapticFeedback.lightImpact);
    try {
      final player = _safeSfxPlayer;
      await player?.setVolume(_getSfxVolume());
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
      final player = _safeSfxPlayer;
      await player?.setVolume(_getSfxVolume());
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
      final player = _safeSfxPlayer;
      await player?.setVolume(_getSfxVolume());
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
      final player = _safeSfxPlayer;
      await player?.setVolume(_getSfxVolume());
      await player?.stop();
      await player?.play(AssetSource('audio/tick.wav'));
    } catch (e) {
      debugPrint('Error playing warning tick audio: $e');
    }
  }

  @override
  Future<void> startBgm() async {
    if (!_isBgmEnabled()) return;
    try {
      final player = _safeBgmPlayer;
      await player?.setVolume(_getBgmVolume());
      await player?.play(AssetSource('audio/bgm.wav'));
    } catch (e) {
      debugPrint('Error starting BGM: $e');
    }
  }

  @override
  Future<void> stopBgm() async {
    try {
      await _bgmPlayer?.stop();
    } catch (e) {
      debugPrint('Error stopping BGM: $e');
    }
  }

  @override
  Future<void> setSfxVolume(double volume) async {
    try {
      await _sfxPlayer?.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  @override
  Future<void> setBgmVolume(double volume) async {
    try {
      await _bgmPlayer?.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      _sfxPlayer?.dispose();
      _bgmPlayer?.dispose();
    } catch (_) {}
  }
}
