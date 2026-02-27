import 'package:flutter/material.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/gallery/presentation/widgets/photo_list_tile.dart';

class ScreenshotsScreen extends StatelessWidget {
  const ScreenshotsScreen({super.key, required this.photos});

  final List<PhotoItem> photos;

  @override
  Widget build(BuildContext context) {
    final items = photos.where((item) => item.isScreenshot).toList();
    if (items.isEmpty) {
      return const Center(child: Text('\uC2A4\uD06C\uB9B0\uC0F7\uC774 \uC5C6\uC2B5\uB2C8\uB2E4.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => PhotoListTile(item: items[index]),
    );
  }
}

