import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stroop/model/services/storage_service.dart';

/// Provider for SharedPreferences instance. Overridden in main.dart or tests.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'Initialize sharedPreferencesProvider in ProviderScope');
});

/// Provider for StorageService (safely returns null if sharedPreferencesProvider is not provided).
final storageServiceProvider = Provider<StorageService?>((ref) {
  try {
    final prefs = ref.watch(sharedPreferencesProvider);
    return StorageService(prefs);
  } catch (_) {
    return null;
  }
});

/// Reactive notifier holding the player's persisted high score.
class HighScoreNotifier extends Notifier<int> {
  @override
  int build() {
    final storage = ref.watch(storageServiceProvider);
    return storage?.getHighScore() ?? 0;
  }

  /// Refreshes high score from storage.
  void refresh() {
    final storage = ref.read(storageServiceProvider);
    state = storage?.getHighScore() ?? 0;
  }
}

/// Provider for reactive HighScoreNotifier.
final highScoreProvider =
    NotifierProvider<HighScoreNotifier, int>(HighScoreNotifier.new);
