import 'package:flutter/material.dart';
import 'package:nostalgia/core/utils/format_bytes.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/gallery/presentation/widgets/photo_card.dart';

enum _ReviewMenuAction { all, selected }

class ReviewBinScreen extends StatefulWidget {
  const ReviewBinScreen({
    super.key,
    required this.photos,
    this.onPhotoTap,
    this.onRestoreAll,
    this.onDeleteAll,
    this.onRestoreSelected,
    this.onDeleteSelected,
  });

  final List<PhotoItem> photos;
  final Future<PhotoItem?> Function(PhotoItem)? onPhotoTap;
  final VoidCallback? onRestoreAll;
  final VoidCallback? onDeleteAll;
  final ValueChanged<Set<String>>? onRestoreSelected;
  final ValueChanged<Set<String>>? onDeleteSelected;

  @override
  State<ReviewBinScreen> createState() => _ReviewBinScreenState();
}

class _ReviewBinScreenState extends State<ReviewBinScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = <String>{};
  final Set<String> _localHiddenIds = <String>{};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<bool> _confirmDelete(int count, {int totalBytes = 0}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 36),
        title: const Text('정말 삭제하시겠습니까?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '선택한 $count개의 사진을 삭제 처리합니다.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (totalBytes > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('예상 확보 용량: ${formatBytes(totalBytes)}'),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withAlpha(80)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '삭제 후에는 보류함에서 복원할 수 없습니다. 중요한 사진이 포함되어 있는지 다시 한번 확인해 주세요.',
                      style: TextStyle(fontSize: 12, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('삭제 확정'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.photos.where((item) => item.inReviewBin && !_localHiddenIds.contains(item.id)).toList();
    final validIds = items.map((item) => item.id).toSet();
    _selectedIds.removeWhere((id) => !validIds.contains(id));
    final totalBytes = items.fold<int>(0, (sum, item) => sum + item.sizeBytes);
    final hasSelection = _selectedIds.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Card(
            child: ListTile(
              title: Text('삭제 후보: ${items.length}개'),
              subtitle: Text('예상 절약 용량: ${formatBytes(totalBytes)}'),
              trailing: Wrap(
                spacing: 8,
                children: [
                  PopupMenuButton<_ReviewMenuAction>(
                    enabled: items.isNotEmpty,
                    tooltip: '보관 메뉴',
                    onSelected: (action) {
                      if (action == _ReviewMenuAction.all) {
                        final ids = items.map((item) => item.id).toSet();
                        setState(() {
                          _localHiddenIds.addAll(ids);
                        });
                        widget.onRestoreAll?.call();
                        setState(() {
                          _isSelectionMode = false;
                          _selectedIds.clear();
                        });
                        return;
                      }
                      _toggleSelectionMode();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<_ReviewMenuAction>(
                        value: _ReviewMenuAction.all,
                        child: Text('모두 보관'),
                      ),
                      PopupMenuItem<_ReviewMenuAction>(
                        value: _ReviewMenuAction.selected,
                        child: Text('선택 보관'),
                      ),
                    ],
                    child: IgnorePointer(
                      child: FilledButton.tonal(
                        onPressed: () {},
                        child: const Text('보관'),
                      ),
                    ),
                  ),
                  PopupMenuButton<_ReviewMenuAction>(
                    enabled: items.isNotEmpty,
                    tooltip: '삭제 메뉴',
                    onSelected: (action) {
                      if (action == _ReviewMenuAction.all) {
                        () async {
                          final confirmed = await _confirmDelete(items.length, totalBytes: totalBytes);
                          if (!confirmed || !mounted) return;
                          final ids = items.map((item) => item.id).toSet();
                          setState(() {
                            _localHiddenIds.addAll(ids);
                            _isSelectionMode = false;
                            _selectedIds.clear();
                          });
                          widget.onDeleteAll?.call();
                        }();
                        return;
                      }
                      _toggleSelectionMode();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<_ReviewMenuAction>(
                        value: _ReviewMenuAction.all,
                        child: Text('모두 삭제'),
                      ),
                      PopupMenuItem<_ReviewMenuAction>(
                        value: _ReviewMenuAction.selected,
                        child: Text('선택 삭제'),
                      ),
                    ],
                    child: IgnorePointer(
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('삭제'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isSelectionMode)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                Text('선택됨 ${_selectedIds.length}개'),
                const Spacer(),
                TextButton(
                  onPressed: hasSelection
                      ? () {
                          final ids = {..._selectedIds};
                          _localHiddenIds.addAll(ids);
                          widget.onRestoreSelected?.call({..._selectedIds});
                          setState(() {
                            _isSelectionMode = false;
                            _selectedIds.clear();
                          });
                        }
                      : null,
                  child: const Text('선택 보관'),
                ),
                TextButton(
                  onPressed: hasSelection
                      ? () async {
                          final ids = {..._selectedIds};
                          final selectedBytes = items
                              .where((item) => ids.contains(item.id))
                              .fold<int>(0, (sum, item) => sum + item.sizeBytes);
                          final confirmed = await _confirmDelete(ids.length, totalBytes: selectedBytes);
                          if (!confirmed || !mounted) return;
                          widget.onDeleteSelected?.call(ids);
                          setState(() {
                            _localHiddenIds.addAll(ids);
                            _isSelectionMode = false;
                            _selectedIds.clear();
                          });
                        }
                      : null,
                  child: const Text('선택 삭제'),
                ),
              ],
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
                    final selected = _selectedIds.contains(item.id);
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: PhotoCard(
                            item: item,
                            onTap: _isSelectionMode
                                ? () => _toggleSelected(item.id)
                                : (widget.onPhotoTap == null
                                      ? null
                                      : () async {
                                          final movedToArchive = await widget.onPhotoTap!(item);
                                          if (!mounted || movedToArchive == null) return;
                                          setState(() {
                                            _localHiddenIds.add(item.id);
                                          });
                                        }),
                          ),
                        ),
                        if (_isSelectionMode)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Icon(
                                selected ? Icons.check : Icons.circle_outlined,
                                size: 14,
                                color: selected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
