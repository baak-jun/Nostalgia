import 'package:flutter/material.dart';
import 'package:nostalgia/features/archive/presentation/archive.screen.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/gallery/presentation/folder_overview.screen.dart';
import 'package:nostalgia/features/review_bin/presentation/review_bin.screen.dart';
import 'package:nostalgia/features/tags/presentation/tag_search.screen.dart';

class CollectionTabsScreen extends StatefulWidget {
  const CollectionTabsScreen({
    super.key,
    required this.allPhotos,
    required this.keptPhotos,
    required this.deferredPhotos,
    this.onArchivePhotoTap,
    this.onArchivePhotoLongPress,
    this.onDeferredPhotoTap,
    this.onFolderPhotoTap,
    this.onRestoreAllDeferred,
    this.onDeleteAllDeferred,
    this.onRestoreSelectedDeferred,
    this.onDeleteSelectedDeferred,
  });

  final List<PhotoItem> allPhotos;
  final List<PhotoItem> keptPhotos;
  final List<PhotoItem> deferredPhotos;
  final ValueChanged<PhotoItem>? onArchivePhotoTap;
  final ValueChanged<PhotoItem>? onArchivePhotoLongPress;
  final Future<PhotoItem?> Function(PhotoItem)? onDeferredPhotoTap;
  final ValueChanged<PhotoItem>? onFolderPhotoTap;
  final VoidCallback? onRestoreAllDeferred;
  final VoidCallback? onDeleteAllDeferred;
  final ValueChanged<Set<String>>? onRestoreSelectedDeferred;
  final ValueChanged<Set<String>>? onDeleteSelectedDeferred;

  @override
  State<CollectionTabsScreen> createState() => _CollectionTabsScreenState();
}

class _CollectionTabsScreenState extends State<CollectionTabsScreen> {
  late List<PhotoItem> _allPhotos;
  late List<PhotoItem> _keptPhotos;
  late List<PhotoItem> _deferredPhotos;

  @override
  void initState() {
    super.initState();
    _allPhotos = List<PhotoItem>.from(widget.allPhotos);
    _keptPhotos = List<PhotoItem>.from(widget.keptPhotos);
    _deferredPhotos = List<PhotoItem>.from(widget.deferredPhotos);
  }

  @override
  void didUpdateWidget(covariant CollectionTabsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.allPhotos, oldWidget.allPhotos)) {
      _allPhotos = List<PhotoItem>.from(widget.allPhotos);
    }
    if (!identical(widget.keptPhotos, oldWidget.keptPhotos)) {
      _keptPhotos = List<PhotoItem>.from(widget.keptPhotos);
    }
    if (!identical(widget.deferredPhotos, oldWidget.deferredPhotos)) {
      _deferredPhotos = List<PhotoItem>.from(widget.deferredPhotos);
    }
  }

  void _replaceAllPhoto(PhotoItem updated) {
    final index = _allPhotos.indexWhere((item) => item.id == updated.id);
    if (index >= 0) {
      _allPhotos[index] = updated;
    } else {
      _allPhotos.add(updated);
    }
  }

  Future<PhotoItem?> _onDeferredPhotoTap(PhotoItem item) async {
    if (widget.onDeferredPhotoTap == null) return null;
    final updated = await widget.onDeferredPhotoTap!(item);
    if (!mounted || updated == null) return updated;
    setState(() {
      _deferredPhotos = _deferredPhotos.where((photo) => photo.id != item.id).toList();
      final restored = updated.copyWith(inReviewBin: false);
      _keptPhotos = <PhotoItem>[..._keptPhotos.where((photo) => photo.id != item.id), restored];
      _replaceAllPhoto(restored);
    });
    return updated;
  }

  void _onArchivePhotoLongPress(PhotoItem item) {
    setState(() {
      _keptPhotos = _keptPhotos.where((photo) => photo.id != item.id).toList();
      final moved = item.copyWith(inReviewBin: true);
      _deferredPhotos = <PhotoItem>[..._deferredPhotos.where((photo) => photo.id != item.id), moved];
      _replaceAllPhoto(moved);
    });
    widget.onArchivePhotoLongPress?.call(item);
  }

  void _onRestoreAllDeferred() {
    setState(() {
      _keptPhotos = <PhotoItem>[
        ..._keptPhotos,
        ..._deferredPhotos
            .map((item) => item.copyWith(inReviewBin: false))
            .where((item) => _keptPhotos.every((kept) => kept.id != item.id)),
      ];
      for (final item in _deferredPhotos) {
        _replaceAllPhoto(item.copyWith(inReviewBin: false));
      }
      _deferredPhotos = const [];
    });
    widget.onRestoreAllDeferred?.call();
  }

  void _onDeleteAllDeferred() {
    final ids = _deferredPhotos.map((item) => item.id).toSet();
    setState(() {
      _deferredPhotos = const [];
      _allPhotos = _allPhotos.where((item) => !ids.contains(item.id)).toList();
    });
    widget.onDeleteAllDeferred?.call();
  }

  void _onRestoreSelectedDeferred(Set<String> ids) {
    setState(() {
      final selected = _deferredPhotos.where((item) => ids.contains(item.id)).toList();
      _deferredPhotos = _deferredPhotos.where((item) => !ids.contains(item.id)).toList();
      _keptPhotos = <PhotoItem>[
        ..._keptPhotos,
        ...selected
            .map((item) => item.copyWith(inReviewBin: false))
            .where((item) => _keptPhotos.every((kept) => kept.id != item.id)),
      ];
      for (final item in selected) {
        _replaceAllPhoto(item.copyWith(inReviewBin: false));
      }
    });
    widget.onRestoreSelectedDeferred?.call(ids);
  }

  void _onDeleteSelectedDeferred(Set<String> ids) {
    setState(() {
      _deferredPhotos = _deferredPhotos.where((item) => !ids.contains(item.id)).toList();
      _allPhotos = _allPhotos.where((item) => !ids.contains(item.id)).toList();
    });
    widget.onDeleteSelectedDeferred?.call(ids);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('사진 화면 이동'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '폴더'),
              Tab(text: '보관함'),
              Tab(text: '보류함'),
              Tab(text: '태그'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FolderOverviewScreen(photos: _allPhotos, onPhotoTap: widget.onFolderPhotoTap),
            ArchiveScreen(
              photos: _keptPhotos,
              onPhotoTap: widget.onArchivePhotoTap,
              onPhotoLongPress: _onArchivePhotoLongPress,
            ),
            ReviewBinScreen(
              photos: _deferredPhotos,
              onPhotoTap: _onDeferredPhotoTap,
              onRestoreAll: _onRestoreAllDeferred,
              onDeleteAll: _onDeleteAllDeferred,
              onRestoreSelected: _onRestoreSelectedDeferred,
              onDeleteSelected: _onDeleteSelectedDeferred,
            ),
            TagSearchScreen(photos: _allPhotos),
          ],
        ),
      ),
    );
  }
}
