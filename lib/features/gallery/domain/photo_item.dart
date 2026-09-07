import 'dart:typed_data';

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
    this.imageBytes,
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
  final Uint8List? imageBytes;
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
    Uint8List? imageBytes,
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
      imageBytes: imageBytes ?? this.imageBytes,
      isScreenshot: isScreenshot ?? this.isScreenshot,
      inReviewBin: inReviewBin ?? this.inReviewBin,
    );
  }
}
