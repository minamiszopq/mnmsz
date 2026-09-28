// デザイン確認用のスクリーンショットを screenshot/out/ に書き出す。
// 通常のテストには含めない。実行:
//   flutter test screenshot/ --update-goldens
// macOS のヒラギノを使うため macOS 上でのみ動く。
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shukatsu_manager/data/database.dart';
import 'package:shukatsu_manager/data/sample_data.dart';
import 'package:shukatsu_manager/features/company_detail/company_detail_screen.dart';
import 'package:shukatsu_manager/features/company_form/company_form_screen.dart';
import 'package:shukatsu_manager/features/home/home_screen.dart';
import 'package:shukatsu_manager/features/settings/settings_screen.dart';
import 'package:shukatsu_manager/providers.dart';
import 'package:shukatsu_manager/settings/settings.dart';
import 'package:shukatsu_manager/theme.dart';

const _font = 'Hiragino';
const _size = Size(393, 852); // iPhone 15 相当

Future<void> _loadFonts() async {
  Future<ByteData> read(String path) async =>
      ByteData.sublistView(await File(path).readAsBytes());
  const sys = '/System/Library/Fonts';
  await (FontLoader(_font)
        ..addFont(read('$sys/ヒラギノ角ゴシック W3.ttc'))
        ..addFont(read('$sys/ヒラギノ角ゴシック W6.ttc')))
      .load();
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  await (FontLoader('MaterialIcons')..addFont(
        read(
          '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
        ),
      ))
      .load();
}

Future<void> _seed(AppDatabase db) async {
  await insertSampleData(db);
  const tech = 2; // テックフロンティア
  await db.customStatement(
    "UPDATE logs SET created_at = created_at - 86400 * 3",
  );
  await db
      .into(db.logs)
      .insert(
        LogsCompanion.insert(
          companyId: tech,
          kind: LogKind.statusChange,
          fromStatus: const Value('書類選考'),
          toStatus: const Value('一次面接'),
          createdAt: Value(DateTime.now().subtract(const Duration(days: 4))),
        ),
      );
  await db
      .into(db.logs)
      .insert(
        LogsCompanion.insert(
          companyId: tech,
          kind: LogKind.memo,
          body: const Value('逆質問を3つ用意する\n・チームの開発体制\n・新卒の育成方針\n・評価制度'),
          createdAt: Value(DateTime.now().subtract(const Duration(days: 1))),
        ),
      );
  await db.customStatement(
    "UPDATE companies SET mypage_id = 'shukatsu2027', "
    "mypage_url = 'https://mypage.example.com/tech' WHERE id = $tech",
  );
}

void main() {
  setUpAll(() async {
    await _loadFonts();
    await initializeDateFormatting('ja');
  });

  Future<void> shoot(
    WidgetTester tester,
    String name,
    Widget Function() screen, {
    bool seed = true,
    ThemeMode mode = ThemeMode.light,
    Future<void> Function()? interact,
  }) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    // ゴールデンテストは既定で影を黒い枠で描くので、実機に近い見た目にする
    debugDisableShadows = false;
    EditableText.debugDeterministicCursor = true;
    tester.view
      ..physicalSize = _size * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // test/ 外に置いているため解析上の警告が出るが、テスト専用コード
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    if (seed) await tester.runAsync(() => _seed(db));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light, fontFamily: _font),
          darkTheme: buildTheme(Brightness.dark, fontFamily: _font),
          themeMode: mode,
          locale: const Locale('ja'),
          supportedLocales: const [Locale('ja')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: screen(),
        ),
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pumpAndSettle();
      }
    }

    await settle();
    if (interact != null) {
      await interact();
      await settle();
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('out/$name.png'),
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
    debugDefaultTargetPlatformOverride = null;
    debugDisableShadows = true;
    EditableText.debugDeterministicCursor = false;
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    final m = mode.name;
    testWidgets(
      'home_$m',
      (t) => shoot(t, 'home_$m', HomeScreen.new, mode: mode),
    );
    testWidgets(
      'detail_$m',
      (t) => shoot(
        t,
        'detail_$m',
        () => const CompanyDetailScreen(companyId: 2),
        mode: mode,
      ),
    );
  }
  testWidgets(
    'home_empty',
    (t) => shoot(t, 'home_empty', HomeScreen.new, seed: false),
  );
  testWidgets(
    'form_edit',
    (t) => shoot(t, 'form_edit', () => const CompanyFormScreen(companyId: 4)),
  );
  testWidgets('settings', (t) => shoot(t, 'settings', SettingsScreen.new));
  testWidgets(
    'settings_dark',
    (t) => shoot(t, 'settings_dark', SettingsScreen.new, mode: ThemeMode.dark),
  );
}
