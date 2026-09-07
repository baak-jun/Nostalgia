import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:nostalgia/features/cloud/data/cloud_drive_service.dart';
import 'package:nostalgia/features/cloud/domain/cloud_drive_models.dart';

class GoogleDriveClient implements ICloudDriveService {
  GoogleDriveClient({
    http.Client? httpClient,
    this.token = '',
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  String token;

  static const String _baseUrl = 'https://www.googleapis.com/drive/v3';

  @override
  CloudDriveType get driveType => CloudDriveType.googleDrive;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  @override
  Future<CloudAccount> signIn({String? customAccessToken}) async {
    if (customAccessToken != null && customAccessToken.isNotEmpty) {
      token = customAccessToken;
    }

    if (token.isEmpty) {
      throw Exception('Google Drive access token is required.');
    }

    // Fetch user info from Google userinfo API
    final response = await _httpClient.get(
      Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return CloudAccount(
        type: CloudDriveType.googleDrive,
        email: data['email'] as String? ?? 'user@gmail.com',
        displayName: data['name'] as String? ?? 'Google User',
        avatarUrl: data['picture'] as String?,
        accessToken: token,
        isConnected: true,
      );
    }

    // Fallback if userinfo endpoint scope is restricted
    return CloudAccount(
      type: CloudDriveType.googleDrive,
      email: 'connected_account@gmail.com',
      displayName: 'Google Drive User',
      accessToken: token,
      isConnected: true,
    );
  }

  @override
  Future<void> signOut() async {
    token = '';
  }

  @override
  Future<List<CloudFileItem>> fetchPhotos({
    String? folderId,
    int pageSize = 100,
    String? pageToken,
  }) async {
    final queryParts = ["mimeType contains 'image/'", "trashed = false"];
    if (folderId != null && folderId.isNotEmpty) {
      queryParts.add("'$folderId' in parents");
    }

    final q = queryParts.join(' and ');
    final uri = Uri.parse('$_baseUrl/files').replace(queryParameters: {
      'q': q,
      'pageSize': pageSize.toString(),
      'fields':
          'nextPageToken, files(id, name, mimeType, size, modifiedTime, thumbnailLink, webViewLink, webContentLink, parents, description, properties)',
      if (pageToken != null) 'pageToken': pageToken,
    });

    final response = await _httpClient.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch photos from Google Drive: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final filesJson = data['files'] as List? ?? [];

    return filesJson.map((file) {
      final f = file as Map<String, dynamic>;
      final rawDesc = f['description'] as String? ?? '';
      final tags = _extractTags(rawDesc, f['properties'] as Map<String, dynamic>?);

      return CloudFileItem(
        id: f['id'] as String,
        name: f['name'] as String? ?? 'Untitled',
        sizeBytes: int.tryParse(f['size']?.toString() ?? '0') ?? 0,
        modifiedTime: DateTime.tryParse(f['modifiedTime'] as String? ?? '') ?? DateTime.now(),
        driveType: CloudDriveType.googleDrive,
        mimeType: f['mimeType'] as String? ?? 'image/jpeg',
        thumbnailUrl: f['thumbnailLink'] as String?,
        webViewLink: f['webViewLink'] as String?,
        downloadUrl: f['webContentLink'] as String?,
        parentFolderId: (f['parents'] as List?)?.firstOrNull as String?,
        tags: tags,
      );
    }).toList();
  }

  @override
  Future<List<CloudFolderItem>> fetchFolders() async {
    final uri = Uri.parse('$_baseUrl/files').replace(queryParameters: {
      'q': "mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      'pageSize': '50',
      'fields': 'files(id, name, parents)',
    });

    final response = await _httpClient.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      return const [];
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final filesJson = data['files'] as List? ?? [];

    return filesJson.map((f) {
      final folder = f as Map<String, dynamic>;
      return CloudFolderItem(
        id: folder['id'] as String,
        name: folder['name'] as String? ?? 'Folder',
        parentId: (folder['parents'] as List?)?.firstOrNull as String?,
        driveType: CloudDriveType.googleDrive,
      );
    }).toList();
  }

  @override
  Future<bool> updateTags(String fileId, List<String> tags) async {
    final uri = Uri.parse('$_baseUrl/files/$fileId');
    final tagString = tags.map((t) => t.trim().replaceAll('#', '')).where((t) => t.isNotEmpty).join(',');
    final body = jsonEncode({
      'description': tagString.isEmpty ? '' : 'tags: $tagString',
      'properties': {'nostalgia_tags': tagString},
    });

    final response = await _httpClient.patch(uri, headers: _headers, body: body);
    return response.statusCode == 200;
  }

  @override
  Future<bool> moveToFolder(String fileId, String targetFolderId) async {
    // In Google Drive v3, move is done via addParents and removeParents
    final metaUri = Uri.parse('$_baseUrl/files/$fileId?fields=parents');
    final metaRes = await _httpClient.get(metaUri, headers: _headers);
    var previousParents = '';
    if (metaRes.statusCode == 200) {
      final meta = jsonDecode(metaRes.body) as Map<String, dynamic>;
      final parents = meta['parents'] as List? ?? [];
      previousParents = parents.join(',');
    }

    final patchUri = Uri.parse('$_baseUrl/files/$fileId').replace(queryParameters: {
      'addParents': targetFolderId,
      if (previousParents.isNotEmpty) 'removeParents': previousParents,
    });

    final response = await _httpClient.patch(patchUri, headers: _headers);
    return response.statusCode == 200;
  }

  @override
  Future<bool> moveToTrash(String fileId) async {
    final uri = Uri.parse('$_baseUrl/files/$fileId');
    final body = jsonEncode({'trashed': true});
    final response = await _httpClient.patch(uri, headers: _headers, body: body);
    return response.statusCode == 200;
  }

  @override
  Future<bool> restoreFromTrash(String fileId) async {
    final uri = Uri.parse('$_baseUrl/files/$fileId');
    final body = jsonEncode({'trashed': false});
    final response = await _httpClient.patch(uri, headers: _headers, body: body);
    return response.statusCode == 200;
  }

  @override
  Future<Uint8List?> fetchThumbnail(String fileId, {String? url}) async {
    if (url != null && url.isNotEmpty) {
      final res = await _httpClient.get(Uri.parse(url), headers: _headers);
      if (res.statusCode == 200) return res.bodyBytes;
    }

    final downloadUri = Uri.parse('$_baseUrl/files/$fileId?alt=media');
    final res = await _httpClient.get(downloadUri, headers: _headers);
    if (res.statusCode == 200) return res.bodyBytes;
    return null;
  }

  List<String> _extractTags(String description, Map<String, dynamic>? properties) {
    if (properties != null && properties.containsKey('nostalgia_tags')) {
      final raw = properties['nostalgia_tags'] as String? ?? '';
      return raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    }
    if (description.startsWith('tags:')) {
      final raw = description.substring(5).trim();
      return raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    }
    return const [];
  }
}
