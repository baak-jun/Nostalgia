import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgia/features/archive/presentation/archive.screen.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';

void main() {
  const tagged = PhotoItem(
    id: '1',
    title: 'tagged-photo',
    dateLabel: '2026-02-27',
    sizeBytes: 100,
    tags: <String>['trip'],
  );

  const untagged = PhotoItem(
    id: '2',
    title: 'untagged-photo',
    dateLabel: '2026-02-27',
    sizeBytes: 200,
    tags: <String>[],
  );

  const markerOnly = PhotoItem(
    id: '3',
    title: 'marker-only-photo',
    dateLabel: '2026-02-27',
    sizeBytes: 300,
    tags: <String>['nostalgia'],
  );

  testWidgets('shows only untagged photos when untagged filter is selected', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ArchiveScreen(photos: <PhotoItem>[tagged, untagged]),
        ),
      ),
    );

    expect(find.text('tagged-photo'), findsOneWidget);
    expect(find.text('untagged-photo'), findsOneWidget);

    await tester.tap(find.text('미태그'));
    await tester.pumpAndSettle();

    expect(find.text('tagged-photo'), findsNothing);
    expect(find.text('untagged-photo'), findsOneWidget);
  });

  testWidgets('marker-only tag is treated as untagged in archive filter', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ArchiveScreen(photos: <PhotoItem>[tagged, markerOnly]),
        ),
      ),
    );

    await tester.tap(find.text('미태그'));
    await tester.pumpAndSettle();

    expect(find.text('tagged-photo'), findsNothing);
    expect(find.text('marker-only-photo'), findsOneWidget);
  });
}
