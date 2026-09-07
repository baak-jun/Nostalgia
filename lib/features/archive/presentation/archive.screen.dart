import 'package:flutter/material.dart';
import 'package:nostalgia/core/utils/tag_rules.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/gallery/presentation/widgets/photo_card.dart';

enum ArchiveFilter { all, untagged }

enum _ArchiveItemMenuAction { moveToReviewBin }

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key, required this.photos, this.onPhotoTap, this.onPhotoLongPress});

  final List<PhotoItem> photos;
  final ValueChanged<PhotoItem>? onPhotoTap;
  final ValueChanged<PhotoItem>? onPhotoLongPress;

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  ArchiveFilter _filter = ArchiveFilter.all;
  final Set<String> _locallyHiddenIds = <String>{};

  List<PhotoItem> get _allPhotos =>
      widget.photos.where((item) => !_locallyHiddenIds.contains(item.id)).toList();
  List<PhotoItem> get _untaggedPhotos =>
      _allPhotos.where((item) => !hasUserVisibleTags(item.tags)).toList();

  Future<void> _showItemMenu(PhotoItem item) async {
    if (widget.onPhotoLongPress == null) return;
    final action = await showModalBottomSheet<_ArchiveItemMenuAction>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.move_down_outlined),
                title: const Text('보류함으로 이동'),
                onTap: () => Navigator.of(context).pop(_ArchiveItemMenuAction.moveToReviewBin),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || action == null) return;
    if (action == _ArchiveItemMenuAction.moveToReviewBin) {
      setState(() {
        _locallyHiddenIds.add(item.id);
      });
      widget.onPhotoLongPress!(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return const Center(child: Text('보관함이 비어 있습니다.'));
    }

    final allPhotos = _allPhotos;
    final untaggedPhotos = _untaggedPhotos;
    final visiblePhotos = _filter == ArchiveFilter.all ? allPhotos : untaggedPhotos;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text('전체 (${allPhotos.length})'),
                  selected: _filter == ArchiveFilter.all,
                  onSelected: (_) => setState(() => _filter = ArchiveFilter.all),
                ),
                ChoiceChip(
                  label: Text('미태그 (${untaggedPhotos.length})'),
                  selected: _filter == ArchiveFilter.untagged,
                  onSelected: (_) => setState(() => _filter = ArchiveFilter.untagged),
                ),
              ],
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
                      onLongPress: widget.onPhotoLongPress == null ? null : () => _showItemMenu(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
