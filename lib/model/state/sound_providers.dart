import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stroop/model/services/audio_service.dart';
import 'package:stroop/model/state/score_providers.dart';

/// Reactive notifier managing user sound effect preference (enabled/muted).
class SoundSettingsNotifier extends Notifier<bool> {
  @override
  bool build() {
    final storage = ref.watch(storageServiceProvider);
    return storage?.isSoundEnabled() ?? true;
  }

  /// Toggles the sound state and persists the new preference.
  Future<void> toggleSound() async {
    final newState = !state;
    state = newState;
    final storage = ref.read(storageServiceProvider);
    await storage?.setSoundEnabled(newState);
  }
}

/// Provider for reactive sound settings.
final soundSettingsProvider =
    NotifierProvider<SoundSettingsNotifier, bool>(SoundSettingsNotifier.new);

/// Provider exposing the AudioService instance.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(
    isSoundEnabled: () => ref.read(soundSettingsProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
