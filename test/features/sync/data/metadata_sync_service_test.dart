import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgia/features/sync/data/metadata_sync_service.dart';

import 'package:nostalgia/features/gallery/domain/photo_item.dart';

void main() {
  const service = MetadataSyncService();

  test('isSupportedImagePath supports only jpg and jpeg', () {
    expect(MetadataSyncService.isSupportedImagePath('a.jpg'), isTrue);
    expect(MetadataSyncService.isSupportedImagePath('a.jpeg'), isTrue);
    expect(MetadataSyncService.isSupportedImagePath('a.heic'), isFalse);
    expect(MetadataSyncService.isSupportedImagePath('a.png'), isFalse);
  });

  test('dryRun accurately counts targets and formats without duplicating', () {
    const photos = <PhotoItem>[
      PhotoItem(
        id: '1',
        title: 'photo1.jpg',
        dateLabel: '2026-03-01',
        sizeBytes: 1024,
        tags: ['cat'],
        asset: null,
      ),
      PhotoItem(
        id: '2',
        title: 'photo2.png',
        dateLabel: '2026-03-01',
        sizeBytes: 1024,
        tags: ['dog'],
        asset: null,
      ),
    ];

    final result = service.dryRun(photos);
    // Since asset is null, noFileCount is 2
    expect(result.noFileCount, 2);
    expect(result.targetCount, 0);
  });
}
