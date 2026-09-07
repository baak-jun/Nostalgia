import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgia/features/cloud/data/cloud_drive_repository.dart';
import 'package:nostalgia/features/cloud/domain/cloud_drive_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CloudDriveRepository & Models Tests', () {
    test('init sets up demo items and default state', () async {
      final repo = CloudDriveRepository();
      await repo.init();

      final gdrivePhotos = await repo.fetchPhotos(CloudDriveType.googleDrive);
      expect(gdrivePhotos, isNotEmpty);
      expect(gdrivePhotos.first.driveType, CloudDriveType.googleDrive);

      final onedrivePhotos = await repo.fetchPhotos(CloudDriveType.oneDrive);
      expect(onedrivePhotos, isNotEmpty);
      expect(onedrivePhotos.first.driveType, CloudDriveType.oneDrive);
    });

    test('CloudFileItem converts to PhotoItem accurately', () {
      final item = CloudFileItem(
        id: 'img123',
        name: 'vacation.jpg',
        sizeBytes: 2048000,
        modifiedTime: DateTime(2026, 3, 5, 10, 0),
        driveType: CloudDriveType.googleDrive,
        tags: const ['trip', 'sea'],
      );

      final photo = item.toPhotoItem();
      expect(photo.id, 'googleDrive_img123');
      expect(photo.title, 'vacation.jpg');
      expect(photo.dateLabel, '2026-03-05');
      expect(photo.sizeBytes, 2048000);
      expect(photo.tags, ['trip', 'sea']);
      expect(photo.inReviewBin, isFalse);
    });

    test('updateTags updates tags for cloud item', () async {
      final repo = CloudDriveRepository();
      await repo.init();

      final initial = await repo.fetchPhotos(CloudDriveType.googleDrive);
      final targetId = initial.first.id;

      final success = await repo.updateTags(
        CloudDriveType.googleDrive,
        targetId,
        ['제주도', '힐링'],
      );
      expect(success, isTrue);

      final updated = await repo.fetchPhotos(CloudDriveType.googleDrive);
      final item = updated.firstWhere((e) => e.id == targetId);
      expect(item.tags, containsAll(['제주도', '힐링']));
    });

    test('moveToReviewBin and restoreFromReviewBin toggle review state', () async {
      final repo = CloudDriveRepository();
      await repo.init();

      final initial = await repo.fetchPhotos(CloudDriveType.oneDrive);
      final targetId = initial.first.id;

      // Move to review bin
      await repo.moveToReviewBin(CloudDriveType.oneDrive, targetId);
      var current = await repo.fetchPhotos(CloudDriveType.oneDrive);
      expect(current.any((e) => e.id == targetId), isFalse);

      // Restore
      await repo.restoreFromReviewBin(CloudDriveType.oneDrive, targetId);
      current = await repo.fetchPhotos(CloudDriveType.oneDrive);
      expect(current.any((e) => e.id == targetId), isTrue);
    });

    test('deletePermanently removes item completely', () async {
      final repo = CloudDriveRepository();
      await repo.init();

      final initial = await repo.fetchPhotos(CloudDriveType.googleDrive);
      final targetId = initial.first.id;
      final initialCount = initial.length;

      await repo.deletePermanently(CloudDriveType.googleDrive, targetId);
      final afterDelete = await repo.fetchPhotos(CloudDriveType.googleDrive);
      expect(afterDelete.length, initialCount - 1);
      expect(afterDelete.any((e) => e.id == targetId), isFalse);
    });

    test('connect and disconnect manage account session', () async {
      final repo = CloudDriveRepository();
      await repo.init();

      expect(repo.isConnected(CloudDriveType.googleDrive), isFalse);

      final account = await repo.connect(CloudDriveType.googleDrive);
      expect(account.isConnected, isTrue);
      expect(repo.isConnected(CloudDriveType.googleDrive), isTrue);

      await repo.disconnect(CloudDriveType.googleDrive);
      expect(repo.isConnected(CloudDriveType.googleDrive), isFalse);
    });
  });
}
