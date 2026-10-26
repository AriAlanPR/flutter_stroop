import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stroop/model/services/storage_service.dart';
import 'package:stroop/model/state/score_providers.dart';
import 'package:stroop/screens/main_menu_screen.dart';
import 'package:stroop/widgets/settings_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('settings-and-polish SettingsDialog tests', () {
    testWidgets('Settings dialog displays persisted volume and toggle states',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        StorageService.keySoundEnabled: true,
        StorageService.keyBgmEnabled: false,
        StorageService.keyHapticsEnabled: true,
        StorageService.keySfxVolume: 0.8,
        StorageService.keyBgmVolume: 0.5,
      });
      final prefs = await SharedPreferences.getInstance();

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

      // Tap settings button in MainMenuScreen
      final settingsButton = find.byKey(const Key('settings_button'));
      expect(settingsButton, findsOneWidget);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDialog), findsOneWidget);
      expect(find.text('SETTINGS'), findsOneWidget);

      // Verify switches reflect stored values
      final sfxSwitch = tester.widget<Switch>(find.byKey(const Key('sfx_switch')));
      expect(sfxSwitch.value, isTrue);

      final bgmSwitch = tester.widget<Switch>(find.byKey(const Key('bgm_switch')));
      expect(bgmSwitch.value, isFalse);

      final hapticsSwitch =
          tester.widget<Switch>(find.byKey(const Key('haptics_switch')));
      expect(hapticsSwitch.value, isTrue);

      // Verify SFX slider exists with value 0.8
      final sfxSlider =
          tester.widget<Slider>(find.byKey(const Key('sfx_volume_slider')));
      expect(sfxSlider.value, 0.8);

      // Close settings dialog
      await tester.tap(find.byKey(const Key('settings_close_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDialog), findsNothing);
    });

    testWidgets('Adjusting settings updates audio output and persists values',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SettingsDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Toggle SFX switch to false
      await tester.tap(find.byKey(const Key('sfx_switch')));
      await tester.pumpAndSettle();
      expect(storage.isSoundEnabled(), isFalse);

      // Toggle Haptics switch to false
      await tester.tap(find.byKey(const Key('haptics_switch')));
      await tester.pumpAndSettle();
      expect(storage.isHapticsEnabled(), isFalse);
    });
  });
}
