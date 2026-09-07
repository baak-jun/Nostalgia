import 'dart:typed_data';
import 'package:nostalgia/features/cloud/domain/cloud_drive_models.dart';

abstract class ICloudDriveService {
  CloudDriveType get driveType;

  Future<CloudAccount> signIn({String? customAccessToken});

  Future<void> signOut();

  Future<List<CloudFileItem>> fetchPhotos({
    String? folderId,
    int pageSize = 100,
    String? pageToken,
  });

  Future<List<CloudFolderItem>> fetchFolders();

  Future<bool> updateTags(String fileId, List<String> tags);

  Future<bool> moveToFolder(String fileId, String targetFolderId);

  Future<bool> moveToTrash(String fileId);

  Future<bool> restoreFromTrash(String fileId);

  Future<Uint8List?> fetchThumbnail(String fileId, {String? url});
}
