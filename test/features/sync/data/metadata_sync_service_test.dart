import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgia/features/sync/data/metadata_sync_service.dart';

void main() {
  test('isSupportedImagePath supports only jpg and jpeg', () {
    expect(MetadataSyncService.isSupportedImagePath('a.jpg'), isTrue);
    expect(MetadataSyncService.isSupportedImagePath('a.jpeg'), isTrue);
    expect(MetadataSyncService.isSupportedImagePath('a.heic'), isFalse);
    expect(MetadataSyncService.isSupportedImagePath('a.png'), isFalse);
  });
}
