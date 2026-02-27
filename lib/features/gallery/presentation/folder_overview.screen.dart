import 'package:flutter/material.dart';
import 'package:nostalgia/core/utils/tag_rules.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/gallery/presentation/gallery.screen.dart';

class FolderOverviewScreen extends StatelessWidget {
  const FolderOverviewScreen({super.key, required this.photos, this.onPhotoTap});

  final List<PhotoItem> photos;
  final ValueChanged<PhotoItem>? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Center(child: Text('표시할 사진이 없습니다.'));
    }

    final grouped = _groupByFolder(photos);
    final folderNames = grouped.keys.toList()..sort();

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: folderNames.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final folderName = folderNames[index];
        final items = grouped[folderName]!;
        final total = items.length;
        final untagged = items.where((item) => !hasUserVisibleTags(item.tags)).length;
        final progress = total == 0 ? 0.0 : (total - untagged) / total;

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _FolderPhotosScreen(
                    folderName: folderName,
                    photos: items,
                    onPhotoTap: onPhotoTap,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(folderName, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('총 $total개  |  미태그 $untagged개'),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, List<PhotoItem>> _groupByFolder(List<PhotoItem> items) {
    final grouped = <String, List<PhotoItem>>{};
    for (final item in items) {
      final folder = _folderName(item.sourcePath);
      grouped.putIfAbsent(folder, () => <PhotoItem>[]).add(item);
    }
    return grouped;
  }

  String _folderName(String? sourcePath) {
    if (sourcePath == null || sourcePath.trim().isEmpty) {
      return 'Unknown';
    }
    final normalized = sourcePath.replaceAll('\\', '/');
    final parts = normalized.split('/').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return 'Unknown';
    }
    return parts.last;
  }
}

class _FolderPhotosScreen extends StatelessWidget {
  const _FolderPhotosScreen({
    required this.folderName,
    required this.photos,
    this.onPhotoTap,
  });

  final String folderName;
  final List<PhotoItem> photos;
  final ValueChanged<PhotoItem>? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(folderName)),
      body: GalleryScreen(photos: photos, onPhotoTap: onPhotoTap),
    );
  }
}
