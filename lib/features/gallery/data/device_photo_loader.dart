import 'package:nostalgia/features/gallery/data/gallery_load_result.dart';
import 'package:nostalgia/features/gallery/data/mock_photo_data.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:photo_manager/photo_manager.dart';

class DevicePhotoLoader {
  const DevicePhotoLoader();

  Future<GalleryLoadResult> load({int limit = 1000}) async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) {
      return const GalleryLoadResult(
        photos: mockPhotos,
        isPermissionDenied: true,
        isUsingMockData: true,
      );
    }

    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (paths.isEmpty) {
      return const GalleryLoadResult(
        photos: [],
        isPermissionDenied: false,
        isUsingMockData: false,
      );
    }

    final assets = await paths.first.getAssetListPaged(page: 0, size: limit);
    final photos = <PhotoItem>[];
    for (final asset in assets) {
      photos.add(await _toPhotoItem(asset));
    }

    return GalleryLoadResult(
      photos: photos,
      isPermissionDenied: false,
      isUsingMockData: false,
    );
  }

  Future<PhotoItem> _toPhotoItem(AssetEntity asset) async {
    var sizeBytes = 0;
    final file = await asset.file;
    if (file != null) {
      sizeBytes = await file.length();
    }

    final title = asset.title?.trim().isNotEmpty == true
        ? asset.title!.trim()
        : '\uC774\uBBF8\uC9C0_${_shortId(asset.id)}';
    final lowerTitle = title.toLowerCase();
    final isScreenshot = lowerTitle.contains('screenshot') || lowerTitle.contains('screen');
    final sourcePath = _resolveSourcePath(asset, isScreenshot);

    return PhotoItem(
      id: asset.id,
      title: title,
      dateLabel: _formatDate(asset.createDateTime),
      sizeBytes: sizeBytes,
      tags: isScreenshot ? const ['\uC2A4\uD06C\uB9B0\uC0F7'] : const [],
      sourcePath: sourcePath,
      asset: asset,
      isScreenshot: isScreenshot,
      inReviewBin: false,
    );
  }

  String _resolveSourcePath(AssetEntity asset, bool isScreenshot) {
    try {
      final dynamic dynamicAsset = asset;
      final String? relativePath = dynamicAsset.relativePath as String?;
      if (relativePath != null && relativePath.trim().isNotEmpty) {
        return relativePath;
      }
    } catch (_) {
      // Fallback below when platform field is unavailable.
    }
    if (isScreenshot) {
      return 'Screenshots';
    }
    return 'Camera';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _shortId(String id) {
    if (id.length <= 6) {
      return id;
    }
    return id.substring(0, 6);
  }
}
