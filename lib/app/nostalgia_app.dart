import 'package:flutter/material.dart';
import 'package:nostalgia/features/home/presentation/home.screen.dart';

class NostalgiaApp extends StatelessWidget {
  const NostalgiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8A8071),
      brightness: Brightness.light,
    ).copyWith(
      surface: const Color(0xFFF3EEE6),
      surfaceContainerHighest: const Color(0xFFE7DFD3),
      primary: const Color(0xFF6F6659),
      secondary: const Color(0xFF8B8276),
      tertiary: const Color(0xFF9A8F80),
    );

    return MaterialApp(
      title: '\uB178\uC2A4\uD0E4\uC9C0\uC5B4',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF6F1E8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFECE4D8),
          foregroundColor: Color(0xFF3F3A34),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFFF8F3EB),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
