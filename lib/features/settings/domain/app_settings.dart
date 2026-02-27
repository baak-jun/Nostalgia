enum SwipeSensitivity { easy, normal, precise }

class AppSettings {
  const AppSettings({
    this.isColorBlindMode = false,
    this.swipeSensitivity = SwipeSensitivity.normal,
  });

  final bool isColorBlindMode;
  final SwipeSensitivity swipeSensitivity;

  AppSettings copyWith({
    bool? isColorBlindMode,
    SwipeSensitivity? swipeSensitivity,
  }) {
    return AppSettings(
      isColorBlindMode: isColorBlindMode ?? this.isColorBlindMode,
      swipeSensitivity: swipeSensitivity ?? this.swipeSensitivity,
    );
  }
}
