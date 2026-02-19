import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A dialog explaining the game rules, styled for a dark theme.
class InstructionsDialog extends StatelessWidget {
  const InstructionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      title: Text('How to Play', style: GoogleFonts.pressStart2p(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Respond to the INK COLOR of the word, not the text itself.',
            style: GoogleFonts.inter(color: Colors.white, height: 1.5),
          ),
          const SizedBox(height: 25),
          const InstructionItem(icon: Icons.arrow_upward, color: Colors.blue, text: 'Swipe Up for Blue'),
          const InstructionItem(icon: Icons.arrow_downward, color: Colors.yellow, text: 'Swipe Down for Yellow'),
          const InstructionItem(icon: Icons.arrow_back, color: Colors.green, text: 'Swipe Left for Green'),
          const InstructionItem(icon: Icons.arrow_forward, color: Colors.red, text: 'Swipe Right for Red'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Got it!', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
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

  const InstructionItem({required this.icon, required this.color, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 15,
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 20),
        Text(text, style: GoogleFonts.inter(fontSize: 16, color: Colors.white)),
      ]),
    );
  }
}
