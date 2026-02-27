import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgia/core/utils/format_bytes.dart';

void main() {
  test('formatBytes formats MB and KB', () {
    expect(formatBytes(1024), '1 KB');
    expect(formatBytes(1024 * 1024), '1.0 MB');
  });
}

