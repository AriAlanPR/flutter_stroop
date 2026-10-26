import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stroop/widgets/instructions_dialog.dart';

void main() {
  group('InstructionsDialog tests', () {
    testWidgets('renders rules and closes on Got it button tap',
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
      expect(find.text('How to Play'), findsOneWidget);
      expect(
        find.text(
            'Respond to the INK COLOR of the word, not the text itself.'),
        findsOneWidget,
      );
      expect(find.byType(InstructionItem), findsNWidgets(4));

      // Close dialog
      await tester.tap(find.text('Got it!'));
      await tester.pumpAndSettle();

      expect(find.byType(InstructionsDialog), findsNothing);
    });
  });
}
