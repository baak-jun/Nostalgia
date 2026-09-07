import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgia/features/tags/presentation/widgets/tag_editor_dialog.dart';

void main() {
  testWidgets('enter adds a tag', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TagEditorDialog(initialTags: <String>{'travel'}),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Receipt');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('#travel'), findsOneWidget);
    expect(find.text('#receipt'), findsOneWidget);
  });

  testWidgets('delete icon removes a tag chip', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TagEditorDialog(initialTags: <String>{'travel', 'receipt'}),
        ),
      ),
    );

    final receiptChip = find.widgetWithText(InputChip, '#receipt');
    expect(receiptChip, findsOneWidget);

    final chip = tester.widget<InputChip>(receiptChip);
    chip.onDeleted!.call();
    await tester.pumpAndSettle();

    expect(find.text('#receipt'), findsNothing);
    expect(find.text('#travel'), findsOneWidget);
  });

  testWidgets('focus stays on text field after pressing enter', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TagEditorDialog(initialTags: <String>{}),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(tester.testTextInput.hasAnyClients, isTrue);

    await tester.enterText(find.byType(TextField), 'family');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('#family'), findsOneWidget);
    expect(tester.testTextInput.hasAnyClients, isTrue);
  });

  testWidgets('empty submit closes dialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog<Set<String>>(
                    context: context,
                    builder: (_) =>
                        const TagEditorDialog(initialTags: <String>{}),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('tapping suggested chip adds it to active tags', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TagEditorDialog(
            initialTags: <String>{'receipt'},
            suggestedTags: <String>{'gallery', 'snack'},
          ),
        ),
      ),
    );

    expect(find.text('#receipt'), findsOneWidget);
    expect(find.text('gallery'), findsOneWidget);
    expect(find.text('snack'), findsOneWidget);

    // Tap suggested chip
    await tester.tap(find.text('gallery'));
    await tester.pumpAndSettle();

    // gallery should now be active with #
    expect(find.text('#gallery'), findsOneWidget);
    // and removed from suggestions
    expect(find.widgetWithText(ActionChip, 'gallery'), findsNothing);
  });

  testWidgets('typing tag with leading # strips prefix cleanly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TagEditorDialog(initialTags: <String>{}),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '#cafe');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('#cafe'), findsOneWidget);
    expect(find.text('##cafe'), findsNothing);
  });
}
