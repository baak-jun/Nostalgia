import 'dart:io';

import 'package:nostalgia/core/utils/tag_rules.dart';
import 'package:native_exif/native_exif.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MetadataSyncDryRunResult {
  const MetadataSyncDryRunResult({
    required this.targetCount,
    required this.unsupportedCount,
    required this.noFileCount,
  });

  final int targetCount;
  final int unsupportedCount;
  final int noFileCount;
}

class MetadataSyncRunResult {
  const MetadataSyncRunResult({
    required this.syncedOriginalIds,
    required this.failedOriginalIds,
    required this.unsupportedOriginalIds,
  });

  final Set<String> syncedOriginalIds;
  final Set<String> failedOriginalIds;
  final Set<String> unsupportedOriginalIds;
}

class MetadataSyncService {
  const MetadataSyncService();

  MetadataSyncDryRunResult dryRun(List<PhotoItem> candidates) {
    var targetCount = 0;
    var unsupportedCount = 0;
    var noFileCount = 0;

    for (final item in candidates) {
      if (item.asset == null) {
        noFileCount++;
        continue;
      }
      if (!isSupportedImagePath(item.title)) {
        unsupportedCount++;
        continue;
      }
      targetCount++;
    }

    return MetadataSyncDryRunResult(
      targetCount: targetCount,
      unsupportedCount: unsupportedCount,
      noFileCount: noFileCount,
    );
  }

  Future<MetadataSyncRunResult> syncToMetadata(List<PhotoItem> candidates) async {
    final synced = <String>{};
    final failed = <String>{};
    final unsupported = <String>{};
    final syncDir = await _ensureSyncDirectory();

    for (final item in candidates) {
      final sourceFile = await item.asset?.file;
      if (sourceFile == null) {
        failed.add(item.id);
        continue;
      }
      if (!isSupportedImagePath(sourceFile.path)) {
        unsupported.add(item.id);
        continue;
      }

      try {
        final copiedPath = await _copyForTagging(item, sourceFile, syncDir);
        final exif = await Exif.fromPath(copiedPath);
        final metadataTags = <String>{...item.tags.map(normalizeTag), metadataSyncMarkerTag}.toList()
          ..sort();
        await exif.writeAttribute('UserComment', metadataTags.join(','));
        final readBack = await exif.getAttribute('UserComment');
        await exif.close();

        if (readBack == null || readBack.trim().isEmpty) {
          failed.add(item.id);
          continue;
        }
        synced.add(item.id);
      } catch (_) {
        failed.add(item.id);
      }
    }

    return MetadataSyncRunResult(
      syncedOriginalIds: synced,
      failedOriginalIds: failed,
      unsupportedOriginalIds: unsupported,
    );
  }

  static bool isSupportedImagePath(String path) {
    final ext = p.extension(path).toLowerCase();
    return ext == '.jpg' || ext == '.jpeg';
  }

  Future<Directory> _ensureSyncDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final syncDir = Directory(p.join(baseDir.path, 'metadata_synced_copies'));
    if (!await syncDir.exists()) {
      await syncDir.create(recursive: true);
    }
    return syncDir;
  }

  Future<String> _copyForTagging(
    PhotoItem item,
    File sourceFile,
    Directory syncDir,
  ) async {
    final ext = p.extension(sourceFile.path).toLowerCase();
    final safeId = item.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filename = '${DateTime.now().millisecondsSinceEpoch}_$safeId$ext';
    final targetPath = p.join(syncDir.path, filename);
    await sourceFile.copy(targetPath);
    return targetPath;
  }
}
