import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoListTile extends StatelessWidget {
  const PhotoListTile({super.key, required this.item});

  final PhotoItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: SizedBox(
          width: 52,
          height: 52,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.asset == null
                ? Container(
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const Icon(Icons.screenshot_monitor_outlined),
                  )
                : FutureBuilder<Uint8List?>(
                    future: item.asset!.thumbnailDataWithSize(
                      const ThumbnailSize.square(200),
                    ),
                    builder: (context, snapshot) {
                      final bytes = snapshot.data;
                      if (bytes == null || bytes.isEmpty) {
                        return Container(
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined),
                        );
                      }
                      return Image.memory(bytes, fit: BoxFit.cover);
                    },
                  ),
          ),
        ),
        title: Text(item.title),
        subtitle: Text(
          item.tags.isEmpty ? '\uD0DC\uADF8 \uC5C6\uC74C' : item.tags.map((tag) => '#$tag').join(' '),
        ),
        trailing: OutlinedButton(
          onPressed: () {},
          child: const Text('\uAC80\uD1A0\uD568'),
        ),
      ),
    );
  }
}
