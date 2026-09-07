import 'package:nostalgia/features/gallery/domain/photo_item.dart';

enum CloudDriveType {
  googleDrive,
  oneDrive;

  String get displayName {
    switch (this) {
      case CloudDriveType.googleDrive:
        return 'Google Drive';
      case CloudDriveType.oneDrive:
        return 'OneDrive';
    }
  }

  String get id => name;
}

class CloudAccount {
  const CloudAccount({
    required this.type,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.accessToken = '',
    this.refreshToken = '',
    this.expiresAt,
    this.isConnected = false,
  });

  final CloudDriveType type;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;
  final bool isConnected;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  CloudAccount copyWith({
    CloudDriveType? type,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    bool? isConnected,
  }) {
    return CloudAccount(
      type: type ?? this.type,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'email': email,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt?.toIso8601String(),
        'isConnected': isConnected,
      };

  factory CloudAccount.fromJson(Map<String, dynamic> json) {
    return CloudAccount(
      type: CloudDriveType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => CloudDriveType.googleDrive,
      ),
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'] as String) : null,
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }
}

class CloudFolderItem {
  const CloudFolderItem({
    required this.id,
    required this.name,
    this.parentId,
    this.driveType = CloudDriveType.googleDrive,
  });

  final String id;
  final String name;
  final String? parentId;
  final CloudDriveType driveType;
}

class CloudFileItem {
  const CloudFileItem({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.modifiedTime,
    required this.driveType,
    this.mimeType = 'image/jpeg',
    this.thumbnailUrl,
    this.webViewLink,
    this.downloadUrl,
    this.parentFolderId,
    this.parentFolderName,
    this.tags = const [],
    this.inReviewBin = false,
  });

  final String id;
  final String name;
  final int sizeBytes;
  final DateTime modifiedTime;
  final CloudDriveType driveType;
  final String mimeType;
  final String? thumbnailUrl;
  final String? webViewLink;
  final String? downloadUrl;
  final String? parentFolderId;
  final String? parentFolderName;
  final List<String> tags;
  final bool inReviewBin;

  String get dateLabel {
    final month = modifiedTime.month.toString().padLeft(2, '0');
    final day = modifiedTime.day.toString().padLeft(2, '0');
    return '${modifiedTime.year}-$month-$day';
  }

  CloudFileItem copyWith({
    String? id,
    String? name,
    int? sizeBytes,
    DateTime? modifiedTime,
    CloudDriveType? driveType,
    String? mimeType,
    String? thumbnailUrl,
    String? webViewLink,
    String? downloadUrl,
    String? parentFolderId,
    String? parentFolderName,
    List<String>? tags,
    bool? inReviewBin,
  }) {
    return CloudFileItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      driveType: driveType ?? this.driveType,
      mimeType: mimeType ?? this.mimeType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      webViewLink: webViewLink ?? this.webViewLink,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      parentFolderName: parentFolderName ?? this.parentFolderName,
      tags: tags ?? this.tags,
      inReviewBin: inReviewBin ?? this.inReviewBin,
    );
  }

  PhotoItem toPhotoItem() {
    return PhotoItem(
      id: '${driveType.name}_$id',
      title: name,
      dateLabel: dateLabel,
      sizeBytes: sizeBytes,
      tags: tags,
      sourcePath: parentFolderName ?? driveType.displayName,
      asset: null,
      isScreenshot: name.toLowerCase().contains('screenshot') || name.toLowerCase().contains('screen'),
      inReviewBin: inReviewBin,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sizeBytes': sizeBytes,
        'modifiedTime': modifiedTime.toIso8601String(),
        'driveType': driveType.name,
        'mimeType': mimeType,
        'thumbnailUrl': thumbnailUrl,
        'webViewLink': webViewLink,
        'downloadUrl': downloadUrl,
        'parentFolderId': parentFolderId,
        'parentFolderName': parentFolderName,
        'tags': tags,
        'inReviewBin': inReviewBin,
      };

  factory CloudFileItem.fromJson(Map<String, dynamic> json) {
    return CloudFileItem(
      id: json['id'] as String,
      name: json['name'] as String,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      modifiedTime: DateTime.tryParse(json['modifiedTime'] as String? ?? '') ?? DateTime.now(),
      driveType: CloudDriveType.values.firstWhere(
        (t) => t.name == json['driveType'],
        orElse: () => CloudDriveType.googleDrive,
      ),
      mimeType: json['mimeType'] as String? ?? 'image/jpeg',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      webViewLink: json['webViewLink'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      parentFolderId: json['parentFolderId'] as String?,
      parentFolderName: json['parentFolderName'] as String?,
      tags: (json['tags'] as List?)?.whereType<String>().toList() ?? const [],
      inReviewBin: json['inReviewBin'] as bool? ?? false,
    );
  }
}
