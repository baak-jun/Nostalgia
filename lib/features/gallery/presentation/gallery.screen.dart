import 'package:flutter/material.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/gallery/presentation/widgets/photo_card.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key, required this.photos, this.onPhotoTap});

  final List<PhotoItem> photos;
  final ValueChanged<PhotoItem>? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Center(child: Text('\uD45C\uC2DC\uD560 \uC0AC\uC9C4\uC774 \uC5C6\uC2B5\uB2C8\uB2E4.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final item = photos[index];
        return PhotoCard(item: item, onTap: onPhotoTap == null ? null : () => onPhotoTap!(item));
      },
    );
  }
}
