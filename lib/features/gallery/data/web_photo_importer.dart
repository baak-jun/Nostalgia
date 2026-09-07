import 'package:file_picker/file_picker.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';

class WebPhotoImporter {
  const WebPhotoImporter();

  Future<List<PhotoItem>> pickPhotos() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return [];
    }

    final now = DateTime.now();
    final dateLabel =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final photos = <PhotoItem>[];
    for (final file in result.files) {
      final bytes = file.bytes;
      final name = file.name;
      final id = 'web_${name.hashCode}_${file.size}';
      photos.add(
        PhotoItem(
          id: id,
          title: name,
          dateLabel: dateLabel,
          sizeBytes: file.size,
          tags: const [],
          imageBytes: bytes,
          sourcePath: 'Web/iCloud',
          isScreenshot: name.toLowerCase().contains('screenshot') ||
              name.toLowerCase().contains('screen'),
          inReviewBin: false,
        ),
      );
    }
    return photos;
  }
}
