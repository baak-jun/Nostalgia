import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/gallery/presentation/folder_overview.screen.dart';

void main() {
  testWidgets('folder overview shows folder stats and untagged count', (tester) async {
    const photos = <PhotoItem>[
      PhotoItem(
        id: '1',
        title: 'cam-1',
        dateLabel: '2026-02-27',
        sizeBytes: 100,
        tags: <String>['trip'],
        sourcePath: 'DCIM/Camera',
      ),
      PhotoItem(
        id: '2',
        title: 'cam-2',
        dateLabel: '2026-02-27',
        sizeBytes: 100,
        tags: <String>[],
        sourcePath: 'DCIM/Camera',
      ),
      PhotoItem(
        id: '3',
        title: 'screen-1',
        dateLabel: '2026-02-27',
        sizeBytes: 100,
        tags: <String>['nostalgia'],
        sourcePath: 'Pictures/Screenshots',
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FolderOverviewScreen(photos: photos),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Screenshots'), findsOneWidget);
    expect(find.text('총 2개  |  미태그 1개'), findsOneWidget);
    expect(find.text('총 1개  |  미태그 1개'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
  });
}
