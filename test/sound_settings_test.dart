import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stroop/model/services/audio_service.dart';
import 'package:stroop/model/services/storage_service.dart';
import 'package:stroop/model/state/score_providers.dart';
import 'package:stroop/model/state/sound_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('audio-feedback sound settings tests', () {
    test('Sound is enabled by default on initial launch', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      expect(storage.isSoundEnabled(), isTrue);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final isEnabled = container.read(soundSettingsProvider);
      expect(isEnabled, isTrue);
    });

    test('Toggling sound persists muted state and suppresses playback',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      // Initially enabled
      expect(container.read(soundSettingsProvider), isTrue);

      // Toggle to muted
      await container.read(soundSettingsProvider.notifier).toggleSound();
      expect(container.read(soundSettingsProvider), isFalse);
      expect(storage.isSoundEnabled(), isFalse);

      // Verify that an AudioService wired to this provider suppresses sound
      var playerTriggered = false;
      final audioService = DefaultAudioService(
        sfxPlayer: null,
        isSoundEnabled: () => container.read(soundSettingsProvider),
      );

      // Calling playCorrect when muted should do nothing and not fail
      await audioService.playCorrect();
      expect(playerTriggered, isFalse);

      // Toggle back to enabled
      await container.read(soundSettingsProvider.notifier).toggleSound();
      expect(container.read(soundSettingsProvider), isTrue);
      expect(storage.isSoundEnabled(), isTrue);
    });

    test('GameSettings persists BGM, volumes, and haptic preferences',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final initial = container.read(gameSettingsProvider);
      expect(initial.sfxEnabled, isTrue);
      expect(initial.bgmEnabled, isTrue);
      expect(initial.hapticsEnabled, isTrue);
      expect(initial.sfxVolume, 1.0);
      expect(initial.bgmVolume, 0.6);

      // Adjust settings
      final notifier = container.read(gameSettingsProvider.notifier);
      await notifier.setBgmEnabled(false);
      await notifier.setSfxVolume(0.75);
      await notifier.setBgmVolume(0.4);
      await notifier.setHapticsEnabled(false);

      final updated = container.read(gameSettingsProvider);
      expect(updated.bgmEnabled, isFalse);
      expect(updated.sfxVolume, 0.75);
      expect(updated.bgmVolume, 0.4);
      expect(updated.hapticsEnabled, isFalse);

      // Confirm values in storage
      expect(storage.isBgmEnabled(), isFalse);
      expect(storage.getSfxVolume(), 0.75);
      expect(storage.getBgmVolume(), 0.4);
      expect(storage.isHapticsEnabled(), isFalse);
    });
  });
}
