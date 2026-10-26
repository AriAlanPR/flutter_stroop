import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// An arcade-styled dialog explaining the Stroop rules and directional mappings.
class InstructionsDialog extends StatelessWidget {
  const InstructionsDialog({super.key});

  /// Static helper to display the instructions dialog.
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const InstructionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              Text(
                'HOW TO PLAY',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 16,
                  color: onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Respond to the INK COLOR of the word, NOT what it spells!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 11,
                    color: onSurface.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4 Directional Cards
              const DirectionCard(
                color: Color(0xFF2196F3),
                colorName: 'BLUE',
                direction: 'UP',
                icon: Icons.arrow_upward,
              ),
              const SizedBox(height: 8),
              const DirectionCard(
                color: Color(0xFFFFEB3B),
                colorName: 'YELLOW',
                direction: 'DOWN',
                icon: Icons.arrow_downward,
                textColor: Colors.black87,
              ),
              const SizedBox(height: 8),
              const DirectionCard(
                color: Color(0xFF4CAF50),
                colorName: 'GREEN',
                direction: 'LEFT',
                icon: Icons.arrow_back,
              ),
              const SizedBox(height: 8),
              const DirectionCard(
                color: Color(0xFFF44336),
                colorName: 'RED',
                direction: 'RIGHT',
                icon: Icons.arrow_forward,
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                key: const Key('instructions_close_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'GOT IT!',
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

/// Stylized arcade card presenting a direction mapping.
class DirectionCard extends StatelessWidget {
  final Color color;
  final String colorName;
  final String direction;
  final IconData icon;
  final Color textColor;

  const DirectionCard({
    super.key,
    required this.color,
    required this.colorName,
    required this.direction,
    required this.icon,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              colorName,
              style: GoogleFonts.pressStart2p(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            direction,
            style: GoogleFonts.pressStart2p(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
