import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/tags/presentation/tag_search.screen.dart';

void main() {
  testWidgets('suggested chips are generated from real tags only', (tester) async {
    const photos = <PhotoItem>[
      PhotoItem(
        id: '1',
        title: 'a',
        dateLabel: '2026-02-27',
        sizeBytes: 1,
        tags: <String>['여행', '가족'],
      ),
      PhotoItem(
        id: '2',
        title: 'b',
        dateLabel: '2026-02-27',
        sizeBytes: 1,
        tags: <String>['여행', 'nostalgia'],
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TagSearchScreen(photos: photos),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ActionChip, '#여행'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, '#가족'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, '#nostalgia'), findsNothing);
    expect(find.text('#영수증'), findsNothing);
  });
}
