import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/home/presentation/collection_tabs.screen.dart';

void main() {
  testWidgets('collection tabs render expected sections', (tester) async {
    const sample = PhotoItem(
      id: '1',
      title: 'sample',
      dateLabel: '2026-02-27',
      sizeBytes: 1200,
      tags: <String>['travel'],
      asset: null,
      isScreenshot: false,
      inReviewBin: false,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: CollectionTabsScreen(
          allPhotos: <PhotoItem>[sample],
          keptPhotos: <PhotoItem>[sample],
          deferredPhotos: <PhotoItem>[],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('폴더'), findsOneWidget);
    expect(find.text('보관함'), findsOneWidget);
    expect(find.text('보류함'), findsOneWidget);
    expect(find.text('태그'), findsOneWidget);
  });

  testWidgets('deferred tab shows empty message when no deferred photos', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CollectionTabsScreen(
          allPhotos: <PhotoItem>[],
          keptPhotos: <PhotoItem>[],
          deferredPhotos: <PhotoItem>[],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('보류함'));
    await tester.pumpAndSettle();

    expect(find.text('검토함이 비어 있습니다.'), findsOneWidget);
  });
}

