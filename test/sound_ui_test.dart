import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stroop/model/state/score_providers.dart';
import 'package:stroop/screens/game_screen.dart';
import 'package:stroop/screens/main_menu_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('audio-feedback UI tests', () {
    testWidgets('Toggling sound in UI updates icon state',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // 1. Test in MainMenuScreen
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: MainMenuScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final toggleButtonFinder = find.byKey(const Key('sound_toggle_button'));
      expect(toggleButtonFinder, findsOneWidget);

      // Initially enabled: shows volume_up icon
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.byIcon(Icons.volume_off), findsNothing);

      // Tap to mute
      await tester.tap(toggleButtonFinder);
      await tester.pumpAndSettle();

      // Muted: shows volume_off icon
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsNothing);

      // 2. Test in GameScreen
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: GameScreen(),
          ),
        ),
      );
      await tester.pump();

      final gameToggleFinder =
          find.byKey(const Key('sound_toggle_button_game'));
      expect(gameToggleFinder, findsOneWidget);

      // Still muted from the previous toggle
      expect(find.byIcon(Icons.volume_off), findsOneWidget);

      // Tap to re-enable sound
      await tester.tap(gameToggleFinder);
      await tester.pump();

      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });
  });
}
