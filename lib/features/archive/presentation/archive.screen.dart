import 'package:flutter/material.dart';
import 'package:nostalgia/core/utils/tag_rules.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/gallery/presentation/widgets/photo_card.dart';

enum ArchiveFilter { all, untagged }

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key, required this.photos, this.onPhotoTap});

  final List<PhotoItem> photos;
  final ValueChanged<PhotoItem>? onPhotoTap;

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  ArchiveFilter _filter = ArchiveFilter.all;

  List<PhotoItem> get _filteredPhotos {
    if (_filter == ArchiveFilter.all) {
      return widget.photos;
    }
    return widget.photos.where((item) => !hasUserVisibleTags(item.tags)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return const Center(child: Text('보관함이 비어 있습니다.'));
    }

    final visiblePhotos = _filteredPhotos;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<ArchiveFilter>(
              segments: const [
                ButtonSegment<ArchiveFilter>(
                  value: ArchiveFilter.all,
                  label: Text('전체'),
                ),
                ButtonSegment<ArchiveFilter>(
                  value: ArchiveFilter.untagged,
                  label: Text('미태그'),
                ),
              ],
              selected: <ArchiveFilter>{_filter},
              onSelectionChanged: (selection) {
                setState(() {
                  _filter = selection.first;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: visiblePhotos.isEmpty
              ? const Center(child: Text('미태그 사진이 없습니다.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: visiblePhotos.length,
                  itemBuilder: (context, index) {
                    final item = visiblePhotos[index];
                    return PhotoCard(
                      item: item,
                      onTap: widget.onPhotoTap == null ? null : () => widget.onPhotoTap!(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
