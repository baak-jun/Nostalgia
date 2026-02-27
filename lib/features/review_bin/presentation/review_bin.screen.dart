import 'package:flutter/material.dart';
import 'package:nostalgia/core/utils/format_bytes.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/gallery/presentation/widgets/photo_card.dart';

class ReviewBinScreen extends StatelessWidget {
  const ReviewBinScreen({super.key, required this.photos, this.onPhotoTap});

  final List<PhotoItem> photos;
  final ValueChanged<PhotoItem>? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final items = photos.where((item) => item.inReviewBin).toList();
    final totalBytes = items.fold<int>(0, (sum, item) => sum + item.sizeBytes);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Card(
            child: ListTile(
              title: Text('삭제 후보: ${items.length}개'),
              subtitle: Text('예상 절약 용량: ${formatBytes(totalBytes)}'),
              trailing: FilledButton(
                onPressed: () {},
                child: const Text('선택 삭제'),
              ),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('검토함이 비어 있습니다.'))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return PhotoCard(
                      item: item,
                      onTap: onPhotoTap == null ? null : () => onPhotoTap!(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
