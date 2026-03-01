import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nostalgia/core/utils/format_bytes.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoCard extends StatelessWidget {
  const PhotoCard({super.key, required this.item, this.onTap, this.onLongPress});

  final PhotoItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _PhotoThumbnail(item: item)),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    '${item.dateLabel} | ${formatBytes(item.sizeBytes)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  if (item.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: item.tags
                          .take(2)
                          .map(
                            (tag) => Chip(
                              label: Text('#$tag'),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({required this.item});

  final PhotoItem item;

  @override
  Widget build(BuildContext context) {
    if (item.asset == null) {
      return Container(
        color: Colors.black12,
        alignment: Alignment.center,
        child: Icon(
          item.isScreenshot ? Icons.screenshot_monitor : Icons.photo,
          size: 42,
        ),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: item.asset!.thumbnailDataWithSize(const ThumbnailSize.square(400)),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return Container(
            color: Colors.black12,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined, size: 32),
          );
        }
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
