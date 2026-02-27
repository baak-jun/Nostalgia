const String metadataSyncMarkerTag = 'nostalgia';

String normalizeTag(String value) => value.trim().toLowerCase();

bool isHiddenAppTag(String tag) => normalizeTag(tag) == metadataSyncMarkerTag;

List<String> visibleTags(Iterable<String> tags) {
  return tags.where((tag) => !isHiddenAppTag(tag)).toList();
}

bool hasUserVisibleTags(Iterable<String> tags) {
  return tags.any((tag) => !isHiddenAppTag(tag));
}
