import 'package:flutter/material.dart';
import 'package:nostalgia/features/archive/presentation/archive.screen.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/gallery/presentation/folder_overview.screen.dart';
import 'package:nostalgia/features/review_bin/presentation/review_bin.screen.dart';
import 'package:nostalgia/features/tags/presentation/tag_search.screen.dart';

class CollectionTabsScreen extends StatelessWidget {
  const CollectionTabsScreen({
    super.key,
    required this.allPhotos,
    required this.keptPhotos,
    required this.deferredPhotos,
    this.onArchivePhotoTap,
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
  final ValueChanged<PhotoItem>? onDeferredPhotoTap;
  final ValueChanged<PhotoItem>? onFolderPhotoTap;
  final VoidCallback? onRestoreAllDeferred;
  final VoidCallback? onDeleteAllDeferred;
  final ValueChanged<Set<String>>? onRestoreSelectedDeferred;
  final ValueChanged<Set<String>>? onDeleteSelectedDeferred;

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
            FolderOverviewScreen(photos: allPhotos, onPhotoTap: onFolderPhotoTap),
            ArchiveScreen(photos: keptPhotos, onPhotoTap: onArchivePhotoTap),
            ReviewBinScreen(
              photos: deferredPhotos,
              onPhotoTap: onDeferredPhotoTap,
              onRestoreAll: onRestoreAllDeferred,
              onDeleteAll: onDeleteAllDeferred,
              onRestoreSelected: onRestoreSelectedDeferred,
              onDeleteSelected: onDeleteSelectedDeferred,
            ),
            TagSearchScreen(photos: allPhotos),
          ],
        ),
      ),
    );
  }
}
