import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';

void main() {
  test('PhotoItem supports imageBytes and copyWith properly', () {
    final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    final item = PhotoItem(
      id: 'test_1',
      title: 'screenshot_2026.png',
      dateLabel: '2026-09-07',
      sizeBytes: 1024,
      tags: const ['test'],
      imageBytes: bytes,
      isScreenshot: true,
      inReviewBin: false,
    );

    expect(item.imageBytes, isNotNull);
    expect(item.imageBytes!.length, 5);
    expect(item.isScreenshot, isTrue);

    final copied = item.copyWith(
      tags: ['test', 'cloud'],
      inReviewBin: true,
    );

    expect(copied.imageBytes, equals(bytes));
    expect(copied.tags, contains('cloud'));
    expect(copied.inReviewBin, isTrue);
  });
}
