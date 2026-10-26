import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stroop/model/services/audio_service.dart';
import 'package:stroop/model/state/score_providers.dart';

/// Immutable model holding all audio, music, and haptic preferences.
class GameSettings {
  final bool sfxEnabled;
  final double sfxVolume;
  final bool bgmEnabled;
  final double bgmVolume;
  final bool hapticsEnabled;

  const GameSettings({
    this.sfxEnabled = true,
    this.sfxVolume = 1.0,
    this.bgmEnabled = true,
    this.bgmVolume = 0.6,
    this.hapticsEnabled = true,
  });

  GameSettings copyWith({
    bool? sfxEnabled,
    double? sfxVolume,
    bool? bgmEnabled,
    double? bgmVolume,
    bool? hapticsEnabled,
  }) {
    return GameSettings(
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      bgmEnabled: bgmEnabled ?? this.bgmEnabled,
      bgmVolume: bgmVolume ?? this.bgmVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}

/// Reactive notifier managing comprehensive game settings and local persistence.
class GameSettingsNotifier extends Notifier<GameSettings> {
  @override
  GameSettings build() {
    final storage = ref.watch(storageServiceProvider);
    if (storage == null) return const GameSettings();

    return GameSettings(
      sfxEnabled: storage.isSoundEnabled(),
      sfxVolume: storage.getSfxVolume(),
      bgmEnabled: storage.isBgmEnabled(),
      bgmVolume: storage.getBgmVolume(),
      hapticsEnabled: storage.isHapticsEnabled(),
    );
  }

  Future<void> setSfxEnabled(bool enabled) async {
    state = state.copyWith(sfxEnabled: enabled);
    final storage = ref.read(storageServiceProvider);
    await storage?.setSoundEnabled(enabled);
  }

  Future<void> setSfxVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(sfxVolume: clamped);
    final storage = ref.read(storageServiceProvider);
    await storage?.setSfxVolume(clamped);
    ref.read(audioServiceProvider).setSfxVolume(clamped);
  }

  Future<void> setBgmEnabled(bool enabled) async {
    state = state.copyWith(bgmEnabled: enabled);
    final storage = ref.read(storageServiceProvider);
    await storage?.setBgmEnabled(enabled);
    if (!enabled) {
      ref.read(audioServiceProvider).stopBgm();
    }
  }

  Future<void> setBgmVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(bgmVolume: clamped);
    final storage = ref.read(storageServiceProvider);
    await storage?.setBgmVolume(clamped);
    ref.read(audioServiceProvider).setBgmVolume(clamped);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    final storage = ref.read(storageServiceProvider);
    await storage?.setHapticsEnabled(enabled);
  }
}

/// Provider for comprehensive game settings.
final gameSettingsProvider =
    NotifierProvider<GameSettingsNotifier, GameSettings>(
        GameSettingsNotifier.new);

/// Backward-compatible provider for sound enabled state (matches sfxEnabled).
class SoundSettingsNotifier extends Notifier<bool> {
  @override
  bool build() {
    final settings = ref.watch(gameSettingsProvider);
    return settings.sfxEnabled;
  }

  Future<void> toggleSound() async {
    final current = ref.read(gameSettingsProvider).sfxEnabled;
    await ref.read(gameSettingsProvider.notifier).setSfxEnabled(!current);
  }
}

final soundSettingsProvider =
    NotifierProvider<SoundSettingsNotifier, bool>(SoundSettingsNotifier.new);

/// Provider exposing the AudioService instance wired to gameSettingsProvider.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = DefaultAudioService(
    isSoundEnabled: () => ref.read(gameSettingsProvider).sfxEnabled,
    isBgmEnabled: () => ref.read(gameSettingsProvider).bgmEnabled,
    isHapticsEnabled: () => ref.read(gameSettingsProvider).hapticsEnabled,
    getSfxVolume: () => ref.read(gameSettingsProvider).sfxVolume,
    getBgmVolume: () => ref.read(gameSettingsProvider).bgmVolume,
  );
  ref.onDispose(service.dispose);
  return service;
});
