import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A dialog explaining the game rules, styled using theme tokens.
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

    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      title: Text(
        'How to Play',
        style: GoogleFonts.pressStart2p(
          fontWeight: FontWeight.bold,
          color: onSurface,
          fontSize: 18,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Respond to the INK COLOR of the word, not the text itself.',
            style: GoogleFonts.inter(color: onSurface, height: 1.5),
          ),
          const SizedBox(height: 25),
          const InstructionItem(
              icon: Icons.arrow_upward,
              color: Colors.blue,
              text: 'Swipe Up for Blue'),
          const InstructionItem(
              icon: Icons.arrow_downward,
              color: Colors.yellow,
              text: 'Swipe Down for Yellow'),
          const InstructionItem(
              icon: Icons.arrow_back,
              color: Colors.green,
              text: 'Swipe Left for Green'),
          const InstructionItem(
              icon: Icons.arrow_forward,
              color: Colors.red,
              text: 'Swipe Right for Red'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Got it!',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

// A single line item in the instructions dialog.
class InstructionItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const InstructionItem(
      {required this.icon,
      required this.color,
      required this.text,
      super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: onSurface.withValues(alpha: 0.12),
          radius: 15,
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 20),
        Text(text, style: GoogleFonts.inter(fontSize: 16, color: onSurface)),
      ]),
    );
  }
}
