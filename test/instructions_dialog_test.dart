import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stroop/widgets/instructions_dialog.dart';

void main() {
  group('InstructionsDialog tests', () {
    testWidgets('Instructions dialog displays retro styled directional cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => InstructionsDialog.show(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open instructions dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(InstructionsDialog), findsOneWidget);
      expect(find.text('HOW TO PLAY'), findsOneWidget);
      expect(
        find.text('Respond to the INK COLOR of the word, NOT what it spells!'),
        findsOneWidget,
      );
      expect(find.byType(DirectionCard), findsNWidgets(4));
      expect(find.text('BLUE'), findsOneWidget);
      expect(find.text('YELLOW'), findsOneWidget);
      expect(find.text('GREEN'), findsOneWidget);
      expect(find.text('RED'), findsOneWidget);

      // Close dialog via GOT IT! button
      await tester.tap(find.text('GOT IT!'));
      await tester.pumpAndSettle();

      expect(find.byType(InstructionsDialog), findsNothing);
    });
  });
}
