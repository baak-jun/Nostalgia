import 'package:photo_manager/photo_manager.dart';

class PhotoItem {
  const PhotoItem({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.sizeBytes,
    required this.tags,
    this.sourcePath,
    this.asset,
    this.isScreenshot = false,
    this.inReviewBin = false,
  });

  final String id;
  final String title;
  final String dateLabel;
  final int sizeBytes;
  final List<String> tags;
  final String? sourcePath;
  final AssetEntity? asset;
  final bool isScreenshot;
  final bool inReviewBin;

  PhotoItem copyWith({
    String? id,
    String? title,
    String? dateLabel,
    int? sizeBytes,
    List<String>? tags,
    String? sourcePath,
    AssetEntity? asset,
    bool? isScreenshot,
    bool? inReviewBin,
  }) {
    return PhotoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      dateLabel: dateLabel ?? this.dateLabel,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      tags: tags ?? this.tags,
      sourcePath: sourcePath ?? this.sourcePath,
      asset: asset ?? this.asset,
      isScreenshot: isScreenshot ?? this.isScreenshot,
      inReviewBin: inReviewBin ?? this.inReviewBin,
    );
  }
}
