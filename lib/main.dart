import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:myapp/screens/main_menu_screen.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

// This widget is the root of your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stroop Game',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3), // Primary color: Blue
          primary: const Color(0xFF2196F3), // Primary color: Blue
          secondary: const Color(0xFF2ECC71), // Accent color: Emerald green
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F4F4), // Background color: Light gray
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}