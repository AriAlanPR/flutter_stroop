import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stroop/main.dart';

void main() {
  testWidgets('MainMenuScreen smoke test renders title and action buttons',
      (WidgetTester tester) async {
    // Build our app wrapped with ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the title 'Stroop Focus' renders
    expect(find.text('Stroop Focus'), findsOneWidget);

    // Verify that the action buttons render with expected keys and text
    expect(find.byKey(const Key('play_button')), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);

    expect(find.byKey(const Key('how_to_play_button')), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);
  });
}
