String formatBytes(int bytes) {
  final kb = bytes / 1024;
  final mb = kb / 1024;
  if (mb >= 1) {
    return '${mb.toStringAsFixed(1)} MB';
  }
  return '${kb.toStringAsFixed(0)} KB';
}

