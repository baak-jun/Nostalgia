import 'dart:convert';
import 'dart:typed_data';
import 'package:nostalgia/features/cloud/data/cloud_drive_service.dart';
import 'package:nostalgia/features/cloud/data/google_drive_client.dart';
import 'package:nostalgia/features/cloud/data/onedrive_client.dart';
import 'package:nostalgia/features/cloud/domain/cloud_drive_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudDriveRepository {
  CloudDriveRepository({
    GoogleDriveClient? googleClient,
    OneDriveClient? oneDriveClient,
  })  : _googleClient = googleClient ?? GoogleDriveClient(),
        _oneDriveClient = oneDriveClient ?? OneDriveClient();

  final GoogleDriveClient _googleClient;
  final OneDriveClient _oneDriveClient;

  static const String _accountsKey = 'nostalgia_cloud_accounts';
  static const String _demoModeKey = 'nostalgia_cloud_demo_mode';

  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  final Map<CloudDriveType, CloudAccount> _accounts = {};
  final List<CloudFileItem> _demoItems = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDemoMode = prefs.getBool(_demoModeKey) ?? false;

    final rawAccounts = prefs.getString(_accountsKey);
    if (rawAccounts != null && rawAccounts.isNotEmpty) {
      try {
        final map = jsonDecode(rawAccounts) as Map<String, dynamic>;
        map.forEach((key, value) {
          final account = CloudAccount.fromJson(value as Map<String, dynamic>);
          _accounts[account.type] = account;
          if (account.type == CloudDriveType.googleDrive) {
            _googleClient.token = account.accessToken;
          } else {
            _oneDriveClient.token = account.accessToken;
          }
        });
      } catch (_) {}
    }

    _initDemoData();
  }

  void _initDemoData() {
    if (_demoItems.isNotEmpty) return;
    _demoItems.addAll([
      CloudFileItem(
        id: 'gdrive_img_01',
        name: '제주도_해변_노을.jpg',
        sizeBytes: 3420000,
        modifiedTime: DateTime(2026, 2, 10, 18, 30),
        driveType: CloudDriveType.googleDrive,
        parentFolderName: 'Google Drive / 여행사진',
        tags: const ['여행', '바다', '노을'],
      ),
      CloudFileItem(
        id: 'gdrive_img_02',
        name: '영수증_스타벅스_0215.jpg',
        sizeBytes: 850000,
        modifiedTime: DateTime(2026, 2, 15, 14, 12),
        driveType: CloudDriveType.googleDrive,
        parentFolderName: 'Google Drive / 영수증',
        tags: const ['영수증', '카페'],
      ),
      CloudFileItem(
        id: 'gdrive_img_03',
        name: '고양이_낮잠.jpg',
        sizeBytes: 4200000,
        modifiedTime: DateTime(2026, 2, 18, 12, 4),
        driveType: CloudDriveType.googleDrive,
        parentFolderName: 'Google Drive / 일상',
        tags: const ['반려동물', '고양이'],
      ),
      CloudFileItem(
        id: 'gdrive_img_04',
        name: '스크린샷_기차예약내역.png',
        sizeBytes: 620000,
        modifiedTime: DateTime(2026, 2, 20, 9, 20),
        driveType: CloudDriveType.googleDrive,
        parentFolderName: 'Google Drive / 스크린샷',
        tags: const ['스크린샷'],
      ),
      CloudFileItem(
        id: 'onedrive_img_01',
        name: '가족모임_생일파티.jpg',
        sizeBytes: 5120000,
        modifiedTime: DateTime(2026, 1, 14, 19, 0),
        driveType: CloudDriveType.oneDrive,
        parentFolderName: 'OneDrive / Pictures',
        tags: const ['가족', '행사'],
      ),
      CloudFileItem(
        id: 'onedrive_img_02',
        name: '서류스캔_계약서.jpg',
        sizeBytes: 1980000,
        modifiedTime: DateTime(2026, 2, 1, 11, 45),
        driveType: CloudDriveType.oneDrive,
        parentFolderName: 'OneDrive / Documents',
        tags: const ['업무', '문서'],
      ),
      CloudFileItem(
        id: 'onedrive_img_03',
        name: '등산_정상_풍경.jpg',
        sizeBytes: 4800000,
        modifiedTime: DateTime(2026, 2, 22, 11, 10),
        driveType: CloudDriveType.oneDrive,
        parentFolderName: 'OneDrive / Pictures',
        tags: const ['풍경', '등산', '여행'],
      ),
      CloudFileItem(
        id: 'onedrive_img_04',
        name: '스크린샷_계좌이체확인.png',
        sizeBytes: 430000,
        modifiedTime: DateTime(2026, 2, 25, 16, 50),
        driveType: CloudDriveType.oneDrive,
        parentFolderName: 'OneDrive / Screenshots',
        tags: const ['스크린샷', '영수증'],
      ),
    ]);
  }

  bool isConnected(CloudDriveType type) {
    if (_isDemoMode) return true;
    final account = _accounts[type];
    return account != null && account.isConnected;
  }

  CloudAccount? getAccount(CloudDriveType type) {
    if (_isDemoMode) {
      return CloudAccount(
        type: type,
        email: type == CloudDriveType.googleDrive ? 'nostalgia.user@gmail.com' : 'nostalgia.user@outlook.com',
        displayName: type == CloudDriveType.googleDrive ? 'Google Drive (데모)' : 'OneDrive (데모)',
        isConnected: true,
      );
    }
    return _accounts[type];
  }

  Future<void> setDemoMode(bool enabled) async {
    _isDemoMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoModeKey, enabled);
  }

  Future<CloudAccount> connect(CloudDriveType type, {String? token}) async {
    if (_isDemoMode || token == null || token.isEmpty) {
      final demoAccount = CloudAccount(
        type: type,
        email: type == CloudDriveType.googleDrive ? 'demo.google@gmail.com' : 'demo.onedrive@outlook.com',
        displayName: type == CloudDriveType.googleDrive ? 'Google Drive 데모' : 'OneDrive 데모',
        accessToken: 'demo_token',
        isConnected: true,
      );
      _accounts[type] = demoAccount;
      await _saveAccounts();
      return demoAccount;
    }

    final ICloudDriveService service = type == CloudDriveType.googleDrive ? _googleClient : _oneDriveClient;
    final account = await service.signIn(customAccessToken: token);
    _accounts[type] = account;
    await _saveAccounts();
    return account;
  }

  Future<void> disconnect(CloudDriveType type) async {
    _accounts.remove(type);
    final ICloudDriveService service = type == CloudDriveType.googleDrive ? _googleClient : _oneDriveClient;
    await service.signOut();
    await _saveAccounts();
  }

  Future<List<CloudFileItem>> fetchPhotos(CloudDriveType type, {String? folderId}) async {
    if (_isDemoMode || !isConnected(type)) {
      return _demoItems.where((item) => item.driveType == type && !item.inReviewBin).toList();
    }

    try {
      final ICloudDriveService service = type == CloudDriveType.googleDrive ? _googleClient : _oneDriveClient;
      return await service.fetchPhotos(folderId: folderId);
    } catch (_) {
      // Fallback to demo items if API network fails
      return _demoItems.where((item) => item.driveType == type && !item.inReviewBin).toList();
    }
  }

  Future<List<CloudFolderItem>> fetchFolders(CloudDriveType type) async {
    if (_isDemoMode || !isConnected(type)) {
      if (type == CloudDriveType.googleDrive) {
        return const [
          CloudFolderItem(id: 'gf1', name: '여행사진', driveType: CloudDriveType.googleDrive),
          CloudFolderItem(id: 'gf2', name: '영수증', driveType: CloudDriveType.googleDrive),
          CloudFolderItem(id: 'gf3', name: '일상', driveType: CloudDriveType.googleDrive),
        ];
      } else {
        return const [
          CloudFolderItem(id: 'of1', name: 'Pictures', driveType: CloudDriveType.oneDrive),
          CloudFolderItem(id: 'of2', name: 'Documents', driveType: CloudDriveType.oneDrive),
          CloudFolderItem(id: 'of3', name: 'Screenshots', driveType: CloudDriveType.oneDrive),
        ];
      }
    }

    final ICloudDriveService service = type == CloudDriveType.googleDrive ? _googleClient : _oneDriveClient;
    return await service.fetchFolders();
  }

  Future<bool> updateTags(CloudDriveType type, String fileId, List<String> tags) async {
    final idx = _demoItems.indexWhere((item) => item.id == fileId);
    if (idx >= 0) {
      _demoItems[idx] = _demoItems[idx].copyWith(tags: tags);
    }

    if (!_isDemoMode && isConnected(type)) {
      try {
        final ICloudDriveService service = type == CloudDriveType.googleDrive ? _googleClient : _oneDriveClient;
        await service.updateTags(fileId, tags);
      } catch (_) {}
    }
    return true;
  }

  Future<bool> moveToReviewBin(CloudDriveType type, String fileId) async {
    final idx = _demoItems.indexWhere((item) => item.id == fileId);
    if (idx >= 0) {
      _demoItems[idx] = _demoItems[idx].copyWith(inReviewBin: true);
    }
    return true;
  }

  Future<bool> restoreFromReviewBin(CloudDriveType type, String fileId) async {
    final idx = _demoItems.indexWhere((item) => item.id == fileId);
    if (idx >= 0) {
      _demoItems[idx] = _demoItems[idx].copyWith(inReviewBin: false);
    }
    return true;
  }

  Future<bool> deletePermanently(CloudDriveType type, String fileId) async {
    _demoItems.removeWhere((item) => item.id == fileId);

    if (!_isDemoMode && isConnected(type)) {
      try {
        final ICloudDriveService service = type == CloudDriveType.googleDrive ? _googleClient : _oneDriveClient;
        await service.moveToTrash(fileId);
      } catch (_) {}
    }
    return true;
  }

  Future<Uint8List?> fetchThumbnail(CloudDriveType type, String fileId, {String? url}) async {
    if (_isDemoMode || !isConnected(type)) {
      return null;
    }
    try {
      final ICloudDriveService service = type == CloudDriveType.googleDrive ? _googleClient : _oneDriveClient;
      return await service.fetchThumbnail(fileId, url: url);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{};
    _accounts.forEach((type, account) {
      map[type.name] = account.toJson();
    });
    await prefs.setString(_accountsKey, jsonEncode(map));
  }
}
