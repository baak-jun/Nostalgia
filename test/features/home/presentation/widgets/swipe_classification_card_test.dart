import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/home/presentation/widgets/swipe_classification_card.dart';
import 'package:nostalgia/features/settings/domain/app_settings.dart';

void main() {
  const sample = PhotoItem(
    id: 'photo-1',
    title: 'sample',
    dateLabel: '2026-02-27',
    sizeBytes: 2048,
    tags: <String>[],
  );

  testWidgets('vertical swipe up triggers skip callback', (tester) async {
    var skipCalled = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwipeClassificationCard(
            key: const ValueKey<String>('swipe-photo-1'),
            item: sample,
            onSwipeLeft: () {},
            onSwipeRight: () {},
            onSwipeUp: () => skipCalled++,
            onSwipeDown: () {},
            isColorBlindMode: false,
            swipeSensitivity: SwipeSensitivity.normal,
          ),
        ),
      ),
    );

    await tester.fling(
      find.byType(SwipeClassificationCard),
      const Offset(0, -800),
      2000,
    );
    await tester.pumpAndSettle();

    expect(skipCalled, 1);
  });
}
