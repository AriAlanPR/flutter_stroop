import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructions'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Play the Stroop Game',
              style: GoogleFonts.inter(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'The Stroop Effect demonstrates interference in reaction time of a task. In this game, you will see words displayed in different ink colors. Your goal is to identify the *ink color* of the word, not the word itself.',
              style: GoogleFonts.inter(fontSize: 18.0),
            ),
            const SizedBox(height: 20),
            Text(
              'For example:',
              style: GoogleFonts.inter(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'If you see the word "RED" written in blue ink, you should respond as if you saw the color blue.',
              style: GoogleFonts.inter(fontSize: 18.0),
            ),
            const SizedBox(height: 20),
            Text(
              'Response Mapping:',
              style: GoogleFonts.inter(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'You can respond using either keyboard arrow keys or by swiping on the screen:',
              style: GoogleFonts.inter(fontSize: 18.0),
            ),
            const SizedBox(height: 10),
            Text(
              '\u2022  Red Ink: Swipe Right / Right Arrow Key\n\n\u2022  Green Ink: Swipe Left / Left Arrow Key\n\n\u2022  Blue Ink: Swipe Up / Up Arrow Key\n\n\u2022  Yellow Ink: Swipe Down / Down Arrow Key',
              style: GoogleFonts.inter(fontSize: 18.0),
            ),
            const SizedBox(height: 20),
            Text(
              'Game Mechanics:',
              style: GoogleFonts.inter(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '\u2022  Correct Answer: Score increases, and you gain 2 seconds on the timer (up to a maximum of 30 seconds).\n\n\u2022  Incorrect Answer: You lose 1 second from the timer.\n\n\u2022  Game Over: The game ends when the timer reaches zero.',
              style: GoogleFonts.inter(fontSize: 18.0),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Go back to the previous screen (MainMenuScreen)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3), // Primary color
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Got It!',
                  style: GoogleFonts.inter(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
