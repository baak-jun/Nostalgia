import 'package:nostalgia/features/gallery/domain/photo_item.dart';

class GalleryLoadResult {
  const GalleryLoadResult({
    required this.photos,
    required this.isPermissionDenied,
    required this.isUsingMockData,
  });

  final List<PhotoItem> photos;
  final bool isPermissionDenied;
  final bool isUsingMockData;
}

