enum SwipeSensitivity { easy, normal, precise }

class AppSettings {
  const AppSettings({
    this.isColorBlindMode = false,
    this.swipeSensitivity = SwipeSensitivity.normal,
    this.syncSamsungFilenameTags = true,
    this.writeExifMetadata = true,
  });

  final bool isColorBlindMode;
  final SwipeSensitivity swipeSensitivity;
  final bool syncSamsungFilenameTags;
  final bool writeExifMetadata;

  AppSettings copyWith({
    bool? isColorBlindMode,
    SwipeSensitivity? swipeSensitivity,
    bool? syncSamsungFilenameTags,
    bool? writeExifMetadata,
  }) {
    return AppSettings(
      isColorBlindMode: isColorBlindMode ?? this.isColorBlindMode,
      swipeSensitivity: swipeSensitivity ?? this.swipeSensitivity,
      syncSamsungFilenameTags: syncSamsungFilenameTags ?? this.syncSamsungFilenameTags,
      writeExifMetadata: writeExifMetadata ?? this.writeExifMetadata,
    );
  }
}
