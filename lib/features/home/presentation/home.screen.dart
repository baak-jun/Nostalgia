import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nostalgia/features/gallery/data/device_photo_loader.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/home/data/home_state_store.dart';
import 'package:nostalgia/features/home/presentation/collection_tabs.screen.dart';
import 'package:nostalgia/features/home/presentation/widgets/swipe_classification_card.dart';
import 'package:nostalgia/features/settings/domain/app_settings.dart';
import 'package:nostalgia/features/settings/presentation/settings.screen.dart';
import 'package:nostalgia/features/sync/data/metadata_sync_service.dart';
import 'package:nostalgia/features/sync/presentation/metadata_sync_dialogs.dart';
import 'package:nostalgia/features/tags/presentation/widgets/tag_editor_dialog.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:nostalgia/core/utils/tag_rules.dart';
enum SortOrder { oldestFirst, newestFirst } enum _SwipeAction { keep, defer, skip }
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final DevicePhotoLoader _loader = const DevicePhotoLoader();
  final HomeStateStore _stateStore = const HomeStateStore();
  final MetadataSyncService _metadataSyncService = const MetadataSyncService();
  bool _isLoading = true;
  bool _isPermissionDenied = false;
  AppSettings _settings = const AppSettings();
  List<PhotoItem> _photos = const [];
  SortOrder _sortOrder = SortOrder.oldestFirst;
  final Set<String> _keptIds = <String>{};
  final Set<String> _deferredIds = <String>{};
  final Set<String> _skippedIds = <String>{};
  final Map<String, Set<String>> _customTagsByPhotoId = <String, Set<String>>{};
  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }
  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    final result = await _loader.load();
    final persisted = await _stateStore.load();
    if (!mounted) return;
    setState(() {
      final loadedIds = result.photos.map((photo) => photo.id).toSet();
      _photos = result.photos;
      _isPermissionDenied = result.isPermissionDenied;
      _keptIds
        ..clear()
        ..addAll(persisted.keptIds.where(loadedIds.contains));
      _deferredIds
        ..clear()
        ..addAll(persisted.deferredIds.where(loadedIds.contains))
        ..removeWhere(_keptIds.contains);
      _skippedIds.clear();
      _customTagsByPhotoId
        ..clear()
        ..addEntries(
          persisted.customTagsByPhotoId.entries
              .where((entry) => loadedIds.contains(entry.key))
              .map((entry) => MapEntry(entry.key, {...entry.value})),
        );
      _isLoading = false;
    });
  }
  List<PhotoItem> get _remainingSorted {
    final remaining = _photos
        .where((item) => !_keptIds.contains(item.id) && !_deferredIds.contains(item.id))
        .map(_applyMutations)
        .toList();
    remaining.sort((a, b) {
      final aHasTags = a.tags.isNotEmpty;
      final bHasTags = b.tags.isNotEmpty;
      if (aHasTags != bHasTags) return aHasTags ? 1 : -1;
      final aSkipped = _skippedIds.contains(a.id);
      final bSkipped = _skippedIds.contains(b.id);
      if (aSkipped != bSkipped) return aSkipped ? 1 : -1;
      final compare = a.dateLabel.compareTo(b.dateLabel);
      return _sortOrder == SortOrder.oldestFirst ? compare : -compare;
    });
    return remaining;
  }
  List<PhotoItem> get _keptPhotos => _photos
      .where((item) => _keptIds.contains(item.id))
      .map((item) => _applyMutations(item, inReviewBin: false))
      .toList();
  List<PhotoItem> get _deferredPhotos => _photos
      .where((item) => _deferredIds.contains(item.id))
      .map((item) => _applyMutations(item, inReviewBin: true))
      .toList();
  List<PhotoItem> get _allPhotosWithMutations => _photos.map(_applyMutations).toList();
  PhotoItem _applyMutations(PhotoItem item, {bool? inReviewBin}) {
    final mergedTags =
        _customTagsByPhotoId[item.id] ??
        <String>{...visibleTags(item.tags.map(_normalizeTag))}..removeWhere((tag) => tag.isEmpty);
    return item.copyWith(
      tags: mergedTags.toList()..sort(),
      inReviewBin: inReviewBin ?? _deferredIds.contains(item.id),
    );
  }
  void _classifyCurrent(_SwipeAction action) {
    final current = _remainingSorted.isEmpty ? null : _remainingSorted.first;
    if (current == null) return;
    setState(() {
      if (action == _SwipeAction.keep) {
        _keptIds.add(current.id);
        _deferredIds.remove(current.id);
        _skippedIds.remove(current.id);
      } else if (action == _SwipeAction.defer) {
        _deferredIds.add(current.id);
        _keptIds.remove(current.id);
        _skippedIds.remove(current.id);
      } else {
        _skippedIds.add(current.id);
      }
    });
    unawaited(_savePersistedState());
  }
  Future<void> _tagCurrent() async {
    final current = _remainingSorted.isEmpty ? null : _remainingSorted.first;
    if (current == null) return;
    await _editTagsForPhoto(current, recoverFromDeferred: false, forceKeepAfterSave: true);
  }
  Future<void> _editTagsForPhoto(
    PhotoItem item, {
    required bool recoverFromDeferred,
    required bool forceKeepAfterSave,
  }) async {
    final initialTags =
        _customTagsByPhotoId[item.id] ??
        <String>{...item.tags.map(_normalizeTag)}..removeWhere((tag) => tag.isEmpty);
    final updatedTags = await showDialog<Set<String>>(
      context: context,
      builder: (context) => TagEditorDialog(initialTags: initialTags),
    );
    if (!mounted || updatedTags == null) return;
    setState(() {
      _customTagsByPhotoId[item.id] = updatedTags;
      if (forceKeepAfterSave) {
        _keptIds.add(item.id);
        _deferredIds.remove(item.id);
        _skippedIds.remove(item.id);
      }
      if (recoverFromDeferred) {
        _deferredIds.remove(item.id);
        _keptIds.add(item.id);
      }
    });
    unawaited(_savePersistedState());
  }
  Future<void> _openCollections() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CollectionTabsScreen(
          allPhotos: _allPhotosWithMutations,
          keptPhotos: _keptPhotos,
          deferredPhotos: _deferredPhotos,
          onArchivePhotoTap: (item) =>
              unawaited(_editTagsForPhoto(item, recoverFromDeferred: false, forceKeepAfterSave: false)),
          onFolderPhotoTap: (item) =>
              unawaited(_editTagsForPhoto(item, recoverFromDeferred: false, forceKeepAfterSave: false)),
          onDeferredPhotoTap: (item) =>
              unawaited(_editTagsForPhoto(item, recoverFromDeferred: true, forceKeepAfterSave: false)),
        ),
      ),
    );
  }
  Future<void> _openSettings() async {
    final updated = await Navigator.of(context).push<AppSettings>(
      MaterialPageRoute<AppSettings>(builder: (_) => SettingsScreen(settings: _settings)),
    );
    if (!mounted || updated == null) return;
    setState(() => _settings = updated);
  }
  List<PhotoItem> _metadataSyncCandidates() {
    return _keptPhotos.where((item) => item.tags.isNotEmpty).toList();
  }
  Future<void> _runMetadataSync() async {
    final candidates = _metadataSyncCandidates();
    final preview = _metadataSyncService.dryRun(candidates);
    final confirmed = await showMetadataSyncConfirmDialog(context, preview: preview);
    if (!mounted || !confirmed) return;
    final result = await _metadataSyncService.syncToMetadata(candidates);
    if (!mounted) return;
    setState(() {
      for (final originalId in result.syncedOriginalIds) {
        _keptIds.remove(originalId);
        _deferredIds.add(originalId);
      }
    });
    await _savePersistedState();
    if (!mounted) return;
    await showMetadataSyncResultDialog(context, result: result);
  }
  Future<void> _savePersistedState() {
    return _stateStore.save(
      keptIds: _keptIds,
      deferredIds: _deferredIds,
      customTagsByPhotoId: _customTagsByPhotoId,
    );
  }
  String _normalizeTag(String value) => value.trim().toLowerCase();
  @override
  Widget build(BuildContext context) {
    final current = _remainingSorted.isEmpty ? null : _remainingSorted.first;
    final totalCount = _photos.length;
    final processedCount = _keptIds.length + _deferredIds.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nostalgia'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: FilledButton.tonalIcon(
              onPressed: _openCollections,
              icon: const Icon(Icons.dashboard_customize_outlined, size: 18),
              label: const Text('화면 이동'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          IconButton(onPressed: _openSettings, icon: const Icon(Icons.tune), tooltip: '설정'),
          IconButton(
            onPressed: _runMetadataSync,
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: '메타 동기화',
          ),
          IconButton(onPressed: _loadPhotos, icon: const Icon(Icons.refresh), tooltip: '다시 불러오기'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isPermissionDenied)
                    MaterialBanner(
                      content: const Text('갤러리 권한이 없어 예시 데이터로 진행합니다.'),
                      actions: [
                        TextButton(onPressed: PhotoManager.openSetting, child: const Text('설정 열기')),
                      ],
                    ),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 8,
                    children: [
                      Text('진행: $processedCount / $totalCount', style: Theme.of(context).textTheme.titleMedium),
                      SegmentedButton<SortOrder>(
                        segments: const [
                          ButtonSegment<SortOrder>(value: SortOrder.oldestFirst, label: Text('오래된순')),
                          ButtonSegment<SortOrder>(value: SortOrder.newestFirst, label: Text('최신순')),
                        ],
                        selected: <SortOrder>{_sortOrder},
                        onSelectionChanged: (selection) => setState(() => _sortOrder = selection.first),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: current == null
                        ? const Center(child: Text('모든 사진 분류가 완료되었습니다.'))
                        : SwipeClassificationCard(
                            key: ValueKey<String>('swipe-${current.id}'),
                            item: current,
                            onSwipeLeft: () => _classifyCurrent(_SwipeAction.defer),
                            onSwipeRight: () => _classifyCurrent(_SwipeAction.keep),
                            onSwipeUp: () => _classifyCurrent(_SwipeAction.skip),
                            onSwipeDown: () => _classifyCurrent(_SwipeAction.skip),
                            isColorBlindMode: _settings.isColorBlindMode,
                            swipeSensitivity: _settings.swipeSensitivity,
                          ),
                  ),
                  const SizedBox(height: 12),
                  const Text('왼쪽: 보류함  |  오른쪽: 보관  |  위/아래: 스킵', textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: current == null ? null : _tagCurrent,
                    icon: const Icon(Icons.sell_outlined),
                    label: const Text('태그 붙이기'),
                  ),
                ],
              ),
            ),
    );
  }
}
