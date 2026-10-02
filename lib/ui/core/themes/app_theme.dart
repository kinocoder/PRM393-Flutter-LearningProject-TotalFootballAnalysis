import 'package:flutter/material.dart';

/// Màu theo 5 mảng chức năng, khớp sơ đồ màn hình.
class AreaColors {
  const AreaColors._();
  static const compare = Color(0xFF3B6FD8); // A
  static const catalog = Color(0xFF2E9D5B); // B
  static const lineup = Color(0xFFD59A10); // C
  static const account = Color(0xFFD0457A); // D
  static const collection = Color(0xFF7C5CD6); // E
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3A2E8C),
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: false),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
    cardTheme: const CardThemeData(margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
  );
}

/// Màu cho giá trị chỉ số (giống cách game tô màu).
Color statColor(BuildContext context, int? value) {
  final scheme = Theme.of(context).colorScheme;
  if (value == null) return scheme.outline;
  if (value >= 100) return const Color(0xFF1E9E4A);
  if (value >= 85) return const Color(0xFF5FAE2E);
  if (value >= 70) return const Color(0xFFD59A10);
  return const Color(0xFFD0453A);
}
