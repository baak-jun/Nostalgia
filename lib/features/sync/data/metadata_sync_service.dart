import 'dart:io';

import 'package:native_exif/native_exif.dart';
import 'package:nostalgia/core/utils/tag_rules.dart';
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
    this.renamedFilesCount = 0,
  });

  final Set<String> syncedOriginalIds;
  final Set<String> failedOriginalIds;
  final Set<String> unsupportedOriginalIds;
  final int renamedFilesCount;
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

  /// Synchronizes tags directly to the original image without duplicating files
  /// or moving originals to the review bin.
  Future<MetadataSyncRunResult> syncToMetadata(
    List<PhotoItem> candidates, {
    bool writeExif = true,
    bool syncSamsungFilenameTags = true,
  }) async {
    final synced = <String>{};
    final failed = <String>{};
    final unsupported = <String>{};
    var renamedCount = 0;

    // Clean up any legacy orphaned copies from previous versions
    await cleanupLegacyCopies();

    for (final item in candidates) {
      final sourceFile = await item.asset?.file;
      if (sourceFile == null || !await sourceFile.exists()) {
        failed.add(item.id);
        continue;
      }
      if (!isSupportedImagePath(sourceFile.path)) {
        unsupported.add(item.id);
        continue;
      }

      final tagsToEmbed = <String>{
        ...item.tags.map(normalizeTag),
        metadataSyncMarkerTag,
      }.where((t) => t.isNotEmpty).toList()..sort();

      var operationSucceeded = false;

      // 1. Write EXIF in-place directly to original file without duplication
      if (writeExif) {
        try {
          final exif = await Exif.fromPath(sourceFile.path);
          final tagString = tagsToEmbed.join(',');
          await exif.writeAttribute('UserComment', tagString);
          await exif.writeAttribute('ImageDescription', tagString);
          await exif.close();
          operationSucceeded = true;
        } catch (_) {
          // If in-place EXIF modification fails (e.g. read-only permission), continue
        }
      }

      // 2. Samsung Gallery Search Optimization: Tag in filename
      if (syncSamsungFilenameTags && item.tags.isNotEmpty) {
        try {
          final renamed = await _applyFilenameTags(sourceFile, item.tags);
          if (renamed) {
            renamedCount++;
            operationSucceeded = true;
          }
        } catch (_) {
          // Non-critical if filesystem denies rename
        }
      }

      if (operationSucceeded || !writeExif) {
        synced.add(item.id);
      } else {
        failed.add(item.id);
      }
    }

    return MetadataSyncRunResult(
      syncedOriginalIds: synced,
      failedOriginalIds: failed,
      unsupportedOriginalIds: unsupported,
      renamedFilesCount: renamedCount,
    );
  }

  /// Appends tag labels into the filename safely (e.g. photo_#trip_#cat.jpg)
  /// so Samsung Gallery search and 'My Files' search instantly find the photo.
  Future<bool> _applyFilenameTags(File file, List<String> rawTags) async {
    final dir = file.parent;
    final ext = p.extension(file.path);
    final baseNameWithoutExt = p.basenameWithoutExtension(file.path);

    // Filter and format tags for filename
    final validTags = rawTags
        .map(normalizeTag)
        .where((t) => t.isNotEmpty && !isHiddenAppTag(t))
        .toSet();
    if (validTags.isEmpty) return false;

    // Remove any existing Nostalgia tag suffixes to avoid infinite accumulation
    final cleanBaseName = baseNameWithoutExt.replaceAll(RegExp(r'(_#[\w가-힣]+)+$'), '');
    final tagSuffix = validTags.map((t) => '_#$t').join('');
    final newFileName = '$cleanBaseName$tagSuffix$ext';
    final newPath = p.join(dir.path, newFileName);

    if (newPath == file.path) {
      return true; // Already has identical tags in name
    }

    final targetFile = File(newPath);
    if (!await targetFile.exists()) {
      await file.rename(newPath);
      return true;
    }
    return false;
  }

  /// Removes any legacy duplicated copies left behind by previous versions.
  static Future<void> cleanupLegacyCopies() async {
    try {
      final baseDir = await getApplicationDocumentsDirectory();
      final syncDir = Directory(p.join(baseDir.path, 'metadata_synced_copies'));
      if (await syncDir.exists()) {
        await syncDir.delete(recursive: true);
      }
    } catch (_) {
      // Ignore cleanup error if directory locked
    }
  }

  static bool isSupportedImagePath(String path) {
    final ext = p.extension(path).toLowerCase();
    return ext == '.jpg' || ext == '.jpeg';
  }
}
