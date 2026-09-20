import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostalgia/core/utils/format_bytes.dart';
import 'package:nostalgia/features/cloud/data/cloud_drive_repository.dart';
import 'package:nostalgia/features/cloud/domain/cloud_drive_models.dart';
import 'package:nostalgia/features/gallery/presentation/widgets/photo_card.dart';
import 'package:nostalgia/features/home/presentation/widgets/swipe_classification_card.dart';
import 'package:nostalgia/features/settings/domain/app_settings.dart';
import 'package:nostalgia/features/tags/presentation/widgets/tag_editor_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class CloudDriveScreen extends StatefulWidget {
  const CloudDriveScreen({
    super.key,
    required this.repository,
    this.settings = const AppSettings(),
  });

  final CloudDriveRepository repository;
  final AppSettings settings;

  @override
  State<CloudDriveScreen> createState() => _CloudDriveScreenState();
}

class _CloudDriveScreenState extends State<CloudDriveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CloudDriveType _currentType = CloudDriveType.googleDrive;

  bool _isLoading = true;
  List<CloudFileItem> _cloudPhotos = [];
  List<CloudFolderItem> _folders = [];
  String? _selectedFolderId;

  final Set<String> _keptIds = {};
  final Set<String> _deferredIds = {};
  final Set<String> _skippedIds = {};
  final Map<String, List<String>> _tagsByFileId = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final newType = _tabController.index == 0 ? CloudDriveType.googleDrive : CloudDriveType.oneDrive;
      if (newType != _currentType) {
        setState(() {
          _currentType = newType;
          _selectedFolderId = null;
        });
        _loadCurrentDrive();
      }
    });

    _loadCurrentDrive();
  }

  Future<void> _loadCurrentDrive() async {
    setState(() => _isLoading = true);
    await widget.repository.init();

    final folders = await widget.repository.fetchFolders(_currentType);
    final photos = await widget.repository.fetchPhotos(_currentType, folderId: _selectedFolderId);

    if (!mounted) return;
    setState(() {
      _folders = folders;
      _cloudPhotos = photos;
      for (final p in photos) {
        _tagsByFileId[p.id] = List.from(p.tags);
        if (p.inReviewBin) {
          _deferredIds.add(p.id);
        }
      }
      _isLoading = false;
    });
  }

  List<CloudFileItem> get _remainingPhotos {
    return _cloudPhotos.where((p) => !_keptIds.contains(p.id) && !_deferredIds.contains(p.id)).toList();
  }

  List<CloudFileItem> get _deferredPhotos {
    return _cloudPhotos.where((p) => _deferredIds.contains(p.id)).toList();
  }

  void _classifyCurrent(bool isKeep) {
    final remaining = _remainingPhotos;
    if (remaining.isEmpty) return;
    final current = remaining.first;

    setState(() {
      if (isKeep) {
        _keptIds.add(current.id);
        _deferredIds.remove(current.id);
      } else {
        _deferredIds.add(current.id);
        _keptIds.remove(current.id);
        widget.repository.moveToReviewBin(_currentType, current.id);
      }
    });
  }

  void _skipCurrent() {
    final remaining = _remainingPhotos;
    if (remaining.isEmpty) return;
    final current = remaining.first;
    setState(() {
      _skippedIds.add(current.id);
      // Rotate skipped item to end
      _cloudPhotos.remove(current);
      _cloudPhotos.add(current);
    });
  }

  Future<void> _editCurrentTags() async {
    final remaining = _remainingPhotos;
    if (remaining.isEmpty) return;
    final current = remaining.first;
    final currentTags = (_tagsByFileId[current.id] ?? current.tags).toSet();
    final allCloudTags = _cloudPhotos
        .expand((p) => _tagsByFileId[p.id] ?? p.tags)
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toSet();

    final updatedTags = await showDialog<Set<String>>(
      context: context,
      builder: (_) => TagEditorDialog(
        initialTags: currentTags,
        suggestedTags: allCloudTags.difference(currentTags),
      ),
    );

    if (!mounted || updatedTags == null) return;
    setState(() {
      _tagsByFileId[current.id] = updatedTags.toList()..sort();
      _keptIds.add(current.id);
      _deferredIds.remove(current.id);
    });

    await widget.repository.updateTags(_currentType, current.id, updatedTags.toList());
  }

  Future<void> _openOAuthTokenPage(CloudDriveType type) async {
    final url = type == CloudDriveType.googleDrive
        ? 'https://developers.google.com/oauthplayground/#step1&apisSelect=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive.readonly%2Chttps%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive.file'
        : 'https://developer.microsoft.com/graph/graph-explorer';
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  Future<void> _connectAccount() async {
    final tokenController = TextEditingController();
    final token = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${_currentType.displayName} 연결'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${_currentType.displayName} 계정으로 로그인하여 사진을 가져옵니다.',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(
                    _currentType == CloudDriveType.googleDrive
                        ? '구글 로그인 & 토큰 발급 페이지 열기'
                        : 'MS 로그인 & 토큰 발급 페이지 열기',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _openOAuthTokenPage(_currentType),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚡ 30초 발급 방법',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Theme.of(ctx).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentType == CloudDriveType.googleDrive
                            ? '1. 위 버튼 클릭 시 구글 OAuth Playground가 열립니다.\n2. [Authorize APIs] 클릭 후 본인 구글 계정 로그인\n3. [Exchange auth code] 클릭 후 나오는 Access Token 복사'
                            : '1. 위 버튼 클릭 시 Graph Explorer가 열립니다.\n2. MS 계정 로그인 후 [Access token] 탭 클릭\n3. 표시된 토큰 복사 후 아래 붙여넣기',
                        style: const TextStyle(fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: tokenController,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Access Token 붙여넣기',
                    hintText: '비워두면 데모 드라이브로 연결됩니다',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.content_paste),
                      tooltip: '클립보드에서 붙여넣기',
                      onPressed: () async {
                        final data = await Clipboard.getData(Clipboard.kTextPlain);
                        if (data?.text != null && data!.text!.trim().isNotEmpty) {
                          tokenController.text = data.text!.trim();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(''),
            child: const Text('데모 모드로 체험하기'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(tokenController.text.trim()),
            child: const Text('연결'),
          ),
        ],
      ),
    );

    if (token == null) return;
    setState(() => _isLoading = true);
    await widget.repository.connect(_currentType, token: token);
    await _loadCurrentDrive();
  }

  Future<void> _disconnectAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('연결 해제'),
        content: Text('${_currentType.displayName} 연결을 해제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('해제')),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.repository.disconnect(_currentType);
      await _loadCurrentDrive();
    }
  }

  void _openReviewBin() {
    final deferred = _deferredPhotos;
    final totalSize = deferred.fold<int>(0, (sum, item) => sum + item.sizeBytes);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final currentDeferred = _deferredPhotos;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text('클라우드 보류함 (${currentDeferred.length}개)', style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                Text('예상 절약 용량: ${formatBytes(totalSize)}'),
                const Divider(height: 20),
                if (currentDeferred.isEmpty)
                  const Expanded(child: Center(child: Text('보류함이 비어 있습니다.')))
                else ...[
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.82,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: currentDeferred.length,
                      itemBuilder: (_, idx) {
                        final item = currentDeferred[idx];
                        return PhotoCard(item: item.toPhotoItem());
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.restore),
                          label: const Text('모두 보관(복원)'),
                          onPressed: () async {
                            for (final item in currentDeferred) {
                              await widget.repository.restoreFromReviewBin(_currentType, item.id);
                            }
                            if (!mounted) return;
                            setState(() {
                              _keptIds.addAll(currentDeferred.map((e) => e.id));
                              _deferredIds.clear();
                            });
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('클라우드 휴지통 이동'),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogCtx) => AlertDialog(
                                icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 36),
                                title: const Text('클라우드 휴지통으로 이동'),
                                content: Text(
                                  '${currentDeferred.length}개의 사진을 ${_currentType.displayName} 휴지통으로 이동합니다.\n삭제를 확정하시겠습니까?',
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false), child: const Text('취소')),
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => Navigator.of(dialogCtx).pop(true),
                                    child: const Text('휴지통 이동'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              for (final item in currentDeferred) {
                                await widget.repository.deletePermanently(_currentType, item.id);
                              }
                              if (!mounted) return;
                              setState(() {
                                _cloudPhotos.removeWhere((p) => _deferredIds.contains(p.id));
                                _deferredIds.clear();
                              });
                              if (ctx.mounted) Navigator.of(ctx).pop();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.repository.getAccount(_currentType);
    final isConnected = widget.repository.isConnected(_currentType);
    final remaining = _remainingPhotos;
    final current = remaining.isEmpty ? null : remaining.first;

    final processedCount = _keptIds.length + _deferredIds.length;
    final totalCount = _cloudPhotos.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('웹드라이브 사진 정리'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_to_drive), text: 'Google Drive'),
            Tab(icon: Icon(Icons.cloud_queue), text: 'OneDrive'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Account Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isConnected ? Colors.green.withAlpha(40) : Colors.grey.withAlpha(40),
                            child: Icon(
                              isConnected ? Icons.cloud_done : Icons.cloud_off,
                              color: isConnected ? Colors.green : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isConnected ? account?.displayName ?? '연결됨' : '연결되지 않음',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  isConnected ? account?.email ?? '' : '로그인하여 사진을 가져오세요',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (isConnected)
                            TextButton(onPressed: _disconnectAccount, child: const Text('연결 해제'))
                          else
                            FilledButton.tonal(onPressed: _connectAccount, child: const Text('연결하기')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Folder Filter & Progress Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String?>(
                        value: _selectedFolderId,
                        hint: const Text('전체 사진'),
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem<String?>(value: null, child: Text('전체 사진')),
                          ..._folders.map(
                            (f) => DropdownMenuItem<String?>(value: f.id, child: Text(f.name)),
                          ),
                        ],
                        onChanged: (folderId) {
                          setState(() => _selectedFolderId = folderId);
                          _loadCurrentDrive();
                        },
                      ),
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('진행: $processedCount / $totalCount'),
                          Badge(
                            isLabelVisible: _deferredIds.isNotEmpty,
                            label: Text('${_deferredIds.length}'),
                            child: OutlinedButton.icon(
                              onPressed: _openReviewBin,
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('보류함'),
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Swipe Classification Card
                  Expanded(
                    child: current == null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                                const SizedBox(height: 12),
                                Text(
                                  totalCount == 0 ? '정리할 클라우드 사진이 없습니다.' : '모든 클라우드 사진 정리가 완료되었습니다!',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                FilledButton.tonal(
                                  onPressed: _loadCurrentDrive,
                                  child: const Text('새로고침'),
                                ),
                              ],
                            ),
                          )
                        : SwipeClassificationCard(
                            key: ValueKey<String>('cloud_swipe_${current.id}'),
                            item: current.copyWith(tags: _tagsByFileId[current.id] ?? current.tags).toPhotoItem(),
                            onSwipeLeft: () => _classifyCurrent(false),
                            onSwipeRight: () => _classifyCurrent(true),
                            onSwipeUp: _skipCurrent,
                            onSwipeDown: _skipCurrent,
                            isColorBlindMode: widget.settings.isColorBlindMode,
                            swipeSensitivity: widget.settings.swipeSensitivity,
                          ),
                  ),
                  const SizedBox(height: 10),

                  // Bottom Action Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton.filledTonal(
                        onPressed: current == null ? null : () => _classifyCurrent(false),
                        tooltip: '보류함 (좌 스와이프)',
                        icon: const Icon(Icons.delete_outline),
                      ),
                      IconButton.filledTonal(
                        onPressed: current == null ? null : _skipCurrent,
                        tooltip: '스킵 (상하 스와이프)',
                        icon: const Icon(Icons.fast_forward_outlined),
                      ),
                      FilledButton.icon(
                        onPressed: current == null ? null : _editCurrentTags,
                        icon: const Icon(Icons.tag),
                        label: const Text('태그 달기'),
                      ),
                      IconButton.filled(
                        onPressed: current == null ? null : () => _classifyCurrent(true),
                        tooltip: '보관 (우 스와이프)',
                        icon: const Icon(Icons.bookmark_add_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
