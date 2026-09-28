import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shukatsu_manager/data/database.dart';
import 'package:shukatsu_manager/features/home/home_screen.dart';
import 'package:shukatsu_manager/providers.dart';
import 'package:shukatsu_manager/settings/settings.dart';

/// インメモリ DB でホーム画面を起動する。
/// テスト末尾で必ず [closeApp] を呼ぶこと。
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  Future<void> Function(AppDatabase db)? seed,
}) async {
  // フォーカス中のカーソル点滅で pumpAndSettle が終わらなくなるのを防ぐ
  EditableText.debugDeterministicCursor = true;
  addTearDown(() => EditableText.debugDeterministicCursor = false);
  await initializeDateFormatting('ja');
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase(NativeDatabase.memory());
  if (seed != null) await tester.runAsync(() => seed(db));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: const MaterialApp(
        locale: Locale('ja'),
        supportedLocales: [Locale('ja')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: HomeScreen(),
      ),
    ),
  );
  await settle(tester);
  return db;
}

/// DB の非同期処理を実時間で進めてから描画を落ち着かせる
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 2; i++) {
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }
}

/// drift のストリーム後始末タイマーを進めてから DB を閉じる
Future<void> closeApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(db.close);
}
