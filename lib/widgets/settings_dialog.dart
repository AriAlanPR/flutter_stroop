import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stroop/model/state/sound_providers.dart';

/// Modal dialog providing interactive arcade-themed game settings.
class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  /// Static helper to display the settings dialog.
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gameSettingsProvider);
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primary.withValues(alpha: 0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SETTINGS',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 18,
                  color: onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // --- SFX Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SOUND FX',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 12,
                      color: onSurface,
                    ),
                  ),
                  Switch(
                    key: const Key('sfx_switch'),
                    value: settings.sfxEnabled,
                    activeTrackColor: primary,
                    onChanged: (val) {
                      ref.read(gameSettingsProvider.notifier).setSfxEnabled(val);
                    },
                  ),
                ],
              ),
              if (settings.sfxEnabled)
                Slider(
                  key: const Key('sfx_volume_slider'),
                  value: settings.sfxVolume,
                  min: 0.0,
                  max: 1.0,
                  activeColor: primary,
                  onChanged: (val) {
                    ref.read(gameSettingsProvider.notifier).setSfxVolume(val);
                  },
                ),

              const Divider(height: 24),

              // --- BGM Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MUSIC (BGM)',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 12,
                      color: onSurface,
                    ),
                  ),
                  Switch(
                    key: const Key('bgm_switch'),
                    value: settings.bgmEnabled,
                    activeTrackColor: primary,
                    onChanged: (val) {
                      ref.read(gameSettingsProvider.notifier).setBgmEnabled(val);
                    },
                  ),
                ],
              ),
              if (settings.bgmEnabled)
                Slider(
                  key: const Key('bgm_volume_slider'),
                  value: settings.bgmVolume,
                  min: 0.0,
                  max: 1.0,
                  activeColor: primary,
                  onChanged: (val) {
                    ref.read(gameSettingsProvider.notifier).setBgmVolume(val);
                  },
                ),

              const Divider(height: 24),

              // --- Haptics Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VIBRATION',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 12,
                      color: onSurface,
                    ),
                  ),
                  Switch(
                    key: const Key('haptics_switch'),
                    value: settings.hapticsEnabled,
                    activeTrackColor: primary,
                    onChanged: (val) {
                      ref
                          .read(gameSettingsProvider.notifier)
                          .setHapticsEnabled(val);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Close Button ---
              ElevatedButton(
                key: const Key('settings_close_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'CLOSE',
                  style: GoogleFonts.pressStart2p(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
