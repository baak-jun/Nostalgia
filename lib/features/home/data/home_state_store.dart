import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePersistedState {
  const HomePersistedState({
    required this.keptIds,
    required this.deferredIds,
    required this.deletedIds,
    required this.customTagsByPhotoId,
  });

  const HomePersistedState.empty()
      : keptIds = const <String>{},
        deferredIds = const <String>{},
        deletedIds = const <String>{},
        customTagsByPhotoId = const <String, Set<String>>{};

  final Set<String> keptIds;
  final Set<String> deferredIds;
  final Set<String> deletedIds;
  final Map<String, Set<String>> customTagsByPhotoId;
}

class HomeStateStore {
  const HomeStateStore();

  static const String _keptIdsKey = 'home_state.kept_ids';
  static const String _deferredIdsKey = 'home_state.deferred_ids';
  static const String _deletedIdsKey = 'home_state.deleted_ids';
  static const String _customTagsKey = 'home_state.custom_tags';

  Future<HomePersistedState> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keptIds = prefs.getStringList(_keptIdsKey) ?? const <String>[];
      final deferredIds = prefs.getStringList(_deferredIdsKey) ?? const <String>[];
      final deletedIds = prefs.getStringList(_deletedIdsKey) ?? const <String>[];
      final customTagsRaw = prefs.getString(_customTagsKey);

      final customTagsByPhotoId = <String, Set<String>>{};
      if (customTagsRaw != null && customTagsRaw.isNotEmpty) {
        final decoded = jsonDecode(customTagsRaw);
        if (decoded is Map<String, dynamic>) {
          decoded.forEach((photoId, value) {
            if (value is List) {
              customTagsByPhotoId[photoId] = value.whereType<String>().toSet();
            }
          });
        }
      }

      return HomePersistedState(
        keptIds: keptIds.toSet(),
        deferredIds: deferredIds.toSet(),
        deletedIds: deletedIds.toSet(),
        customTagsByPhotoId: customTagsByPhotoId,
      );
    } on MissingPluginException {
      return const HomePersistedState.empty();
    }
  }

  Future<void> save({
    required Set<String> keptIds,
    required Set<String> deferredIds,
    required Set<String> deletedIds,
    required Map<String, Set<String>> customTagsByPhotoId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tagsToSave = <String, List<String>>{};
      customTagsByPhotoId.forEach((photoId, tags) {
        if (tags.isNotEmpty) {
          tagsToSave[photoId] = tags.toList()..sort();
        }
      });

      await prefs.setStringList(_keptIdsKey, keptIds.toList()..sort());
      await prefs.setStringList(_deferredIdsKey, deferredIds.toList()..sort());
      await prefs.setStringList(_deletedIdsKey, deletedIds.toList()..sort());
      await prefs.setString(_customTagsKey, jsonEncode(tagsToSave));
    } on MissingPluginException {
      // Plugin unavailable in current runtime (e.g., stale hot-restart instance).
      // Keep app functional and skip persistence for this session.
    }
  }
}
