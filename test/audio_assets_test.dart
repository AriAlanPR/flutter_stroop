import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Audio asset files exist in asset bundle and are non-empty', () async {
    // Check assets/audio/ (standard audioplayers root)
    final correctBytes = await rootBundle.load('assets/audio/correct.wav');
    expect(correctBytes.lengthInBytes, greaterThan(0));

    final incorrectBytes = await rootBundle.load('assets/audio/incorrect.wav');
    expect(incorrectBytes.lengthInBytes, greaterThan(0));

    final gameOverBytes = await rootBundle.load('assets/audio/game_over.wav');
    expect(gameOverBytes.lengthInBytes, greaterThan(0));

    final tickBytes = await rootBundle.load('assets/audio/tick.wav');
    expect(tickBytes.lengthInBytes, greaterThan(0));
  });
}
