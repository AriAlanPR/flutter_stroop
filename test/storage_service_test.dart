import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stroop/model/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('score-persistence storage tests', () {
    test('Initial launch with no saved records defaults high score to zero',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      expect(storage.getHighScore(), 0);
      expect(storage.getTotalGamesPlayed(), 0);
    });

    test('Achieving a score higher than current high score updates record',
        () async {
      SharedPreferences.setMockInitialValues({
        StorageService.keyHighScore: 10,
        StorageService.keyTotalGames: 2,
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final isNewRecord = await storage.recordGamePlayed(15);

      expect(isNewRecord, isTrue);
      expect(storage.getHighScore(), 15);
      expect(storage.getTotalGamesPlayed(), 3);
    });

    test('Achieving a score lower than current high score preserves record',
        () async {
      SharedPreferences.setMockInitialValues({
        StorageService.keyHighScore: 20,
        StorageService.keyTotalGames: 5,
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final isNewRecord = await storage.recordGamePlayed(12);

      expect(isNewRecord, isFalse);
      expect(storage.getHighScore(), 20);
      expect(storage.getTotalGamesPlayed(), 6);
    });
  });
}
