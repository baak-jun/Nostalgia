import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:nostalgia/features/cloud/data/cloud_drive_service.dart';
import 'package:nostalgia/features/cloud/domain/cloud_drive_models.dart';

class OneDriveClient implements ICloudDriveService {
  OneDriveClient({
    http.Client? httpClient,
    this.token = '',
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  String token;

  static const String _baseUrl = 'https://graph.microsoft.com/v1.0';

  @override
  CloudDriveType get driveType => CloudDriveType.oneDrive;

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
      throw Exception('OneDrive access token is required.');
    }

    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final email = (data['mail'] ?? data['userPrincipalName'] ?? 'user@outlook.com') as String;
      final displayName = (data['displayName'] ?? 'OneDrive User') as String;

      return CloudAccount(
        type: CloudDriveType.oneDrive,
        email: email,
        displayName: displayName,
        accessToken: token,
        isConnected: true,
      );
    }

    return CloudAccount(
      type: CloudDriveType.oneDrive,
      email: 'connected_account@outlook.com',
      displayName: 'OneDrive User',
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
    final String endpoint;
    if (folderId != null && folderId.isNotEmpty) {
      endpoint = '$_baseUrl/me/drive/items/$folderId/children';
    } else {
      endpoint = '$_baseUrl/me/drive/root/search(q=\'\')';
    }

    final uri = Uri.parse(endpoint).replace(queryParameters: {
      r'$top': pageSize.toString(),
      r'$select': 'id,name,size,file,lastModifiedDateTime,webUrl,parentReference,description',
      if (pageToken != null) r'$skiptoken': pageToken,
    });

    final response = await _httpClient.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch photos from OneDrive: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['value'] as List? ?? []).whereType<Map<String, dynamic>>();

    final photos = <CloudFileItem>[];
    for (final item in items) {
      final fileObj = item['file'] as Map<String, dynamic>?;
      final mimeType = fileObj?['mimeType'] as String? ?? '';
      if (!mimeType.startsWith('image/')) continue;

      final desc = item['description'] as String? ?? '';
      final tags = _extractTags(desc);
      final id = item['id'] as String;
      final parentRef = item['parentReference'] as Map<String, dynamic>?;

      photos.add(
        CloudFileItem(
          id: id,
          name: item['name'] as String? ?? 'Untitled',
          sizeBytes: (item['size'] as num?)?.toInt() ?? 0,
          modifiedTime: DateTime.tryParse(item['lastModifiedDateTime'] as String? ?? '') ?? DateTime.now(),
          driveType: CloudDriveType.oneDrive,
          mimeType: mimeType,
          thumbnailUrl: '$_baseUrl/me/drive/items/$id/thumbnails/0/medium/content',
          webViewLink: item['webUrl'] as String?,
          parentFolderId: parentRef?['id'] as String?,
          parentFolderName: parentRef?['name'] as String?,
          tags: tags,
        ),
      );
    }

    return photos;
  }

  @override
  Future<List<CloudFolderItem>> fetchFolders() async {
    final uri = Uri.parse('$_baseUrl/me/drive/root/children').replace(queryParameters: {
      r'$filter': 'folder ne null',
      r'$select': 'id,name,parentReference',
    });

    final response = await _httpClient.get(uri, headers: _headers);
    if (response.statusCode != 200) return const [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['value'] as List? ?? []).whereType<Map<String, dynamic>>();

    return items.map((f) {
      final parentRef = f['parentReference'] as Map<String, dynamic>?;
      return CloudFolderItem(
        id: f['id'] as String,
        name: f['name'] as String? ?? 'Folder',
        parentId: parentRef?['id'] as String?,
        driveType: CloudDriveType.oneDrive,
      );
    }).toList();
  }

  @override
  Future<bool> updateTags(String fileId, List<String> tags) async {
    final uri = Uri.parse('$_baseUrl/me/drive/items/$fileId');
    final tagString = tags.map((t) => t.trim().replaceAll('#', '')).where((t) => t.isNotEmpty).join(',');
    final body = jsonEncode({
      'description': tagString.isEmpty ? '' : 'tags: $tagString',
    });

    final response = await _httpClient.patch(uri, headers: _headers, body: body);
    return response.statusCode == 200;
  }

  @override
  Future<bool> moveToFolder(String fileId, String targetFolderId) async {
    final uri = Uri.parse('$_baseUrl/me/drive/items/$fileId');
    final body = jsonEncode({
      'parentReference': {'id': targetFolderId},
    });

    final response = await _httpClient.patch(uri, headers: _headers, body: body);
    return response.statusCode == 200;
  }

  @override
  Future<bool> moveToTrash(String fileId) async {
    // In Microsoft Graph, DELETE on a drive item moves it to the Recycle Bin
    final uri = Uri.parse('$_baseUrl/me/drive/items/$fileId');
    final response = await _httpClient.delete(uri, headers: _headers);
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<bool> restoreFromTrash(String fileId) async {
    final uri = Uri.parse('$_baseUrl/me/drive/items/$fileId/restore');
    final response = await _httpClient.post(uri, headers: _headers);
    return response.statusCode == 200;
  }

  @override
  Future<Uint8List?> fetchThumbnail(String fileId, {String? url}) async {
    final fetchUrl = url ?? '$_baseUrl/me/drive/items/$fileId/thumbnails/0/medium/content';
    final res = await _httpClient.get(Uri.parse(fetchUrl), headers: _headers);
    if (res.statusCode == 200) return res.bodyBytes;
    return null;
  }

  List<String> _extractTags(String description) {
    if (description.startsWith('tags:')) {
      final raw = description.substring(5).trim();
      return raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    }
    return const [];
  }
}
