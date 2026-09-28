import 'package:flutter/material.dart';

import 'data/database.dart';

/// ブランドカラー(落ち着いたインディゴ)
const _seed = Color(0xFF4F5BD5);

ThemeData buildTheme(Brightness brightness, {String? fontFamily}) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final radius = BorderRadius.circular(16);
  final dark = brightness == Brightness.dark;
  // ライトは「薄く色づいた背景 + 白いカード」、ダークは「暗い背景 + 一段明るいカード」
  final background = dark ? scheme.surface : scheme.surfaceContainerLow;
  final cardColor = dark
      ? scheme.surfaceContainerHigh
      : scheme.surfaceContainerLowest;
  return ThemeData(
    colorScheme: scheme,
    fontFamily: fontFamily,
    useMaterial3: true,
    // 背景をわずかに色づけし、カードを一段明るくして区別する
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: radius),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.5),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(color: scheme.outlineVariant),
    ),
    tabBarTheme: TabBarThemeData(
      dividerColor: Colors.transparent,
      labelStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: TextStyle(fontFamily: fontFamily),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

/// 選考状態バッジの (背景色, 文字色)
(Color, Color) statusColors(BuildContext context, StatusCategory category) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final (light, darkPair) = switch (category) {
    // エントリー: 控えめなスレート
    StatusCategory.entry => (
      (const Color(0xFFE7EAF0), const Color(0xFF3D4656)),
      (const Color(0xFF353B47), const Color(0xFFD5DAE3)),
    ),
    // 選考中: ブランドに近い青
    StatusCategory.inProgress => (
      (const Color(0xFFDDE3FF), const Color(0xFF2A3AA8)),
      (const Color(0xFF2C3570), const Color(0xFFD4DBFF)),
    ),
    // 内定: 緑
    StatusCategory.offer => (
      (const Color(0xFFD6F2DF), const Color(0xFF17643A)),
      (const Color(0xFF1D4A30), const Color(0xFFC2EDD1)),
    ),
    // 終了: グレー
    StatusCategory.closed => (
      (const Color(0xFFEDEDED), const Color(0xFF6B6B6B)),
      (const Color(0xFF3A3A3A), const Color(0xFFB0B0B0)),
    ),
  };
  return dark ? darkPair : light;
}
