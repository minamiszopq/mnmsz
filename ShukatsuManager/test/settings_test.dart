import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shukatsu_manager/features/home/home_screen.dart';
import 'package:shukatsu_manager/features/settings/settings_screen.dart';
import 'package:shukatsu_manager/settings/settings.dart';

import 'helpers.dart';

Future<ProviderContainer> container([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('初期値', () async {
    final s = (await container()).read(settingsProvider);
    expect(s.notificationsEnabled, isTrue);
    expect(s.defaultReminderMinutes, {1440, 60});
    expect(s.highlightDays, 3);
    expect(s.themeMode, ThemeMode.system);
  });

  test('保存した値が次回起動時に読み込まれる', () async {
    final c = await container();
    final n = c.read(settingsProvider.notifier);
    await n.setNotificationsEnabled(false);
    await n.setDefaultReminderMinutes({4320});
    await n.setHighlightDays(7);
    await n.setThemeMode(ThemeMode.dark);

    final prefs = await SharedPreferences.getInstance();
    final reopened = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(reopened.dispose);
    final s = reopened.read(settingsProvider);
    expect(s.notificationsEnabled, isFalse);
    expect(s.defaultReminderMinutes, {4320});
    expect(s.highlightDays, 7);
    expect(s.themeMode, ThemeMode.dark);
  });

  test('範囲外の保存値は丸める', () async {
    final s = (await container({'highlightDays': 99})).read(settingsProvider);
    expect(s.highlightDays, AppSettings.maxHighlightDays);
  });

  test('formatReminders は早い順に並べる', () {
    expect(formatReminders({60, 10080, 1440}), '1週間前・前日・1時間前');
    expect(formatReminders({}), '通知しない');
  });

  testWidgets('設定画面で強調日数を変えると一覧の強調が変わる', (tester) async {
    final db = await pumpApp(
      tester,
      seed: (db) async {
        // 5日後に予定がある企業 → 初期値3日では強調されない
        await db.customStatement(
          "INSERT INTO companies (name, status_id) VALUES ('強調テスト社', 1)",
        );
        await db.customStatement(
          'INSERT INTO events (company_id, type, starts_at) VALUES (1, 0, ?)',
          [
            DateTime.now()
                    .add(const Duration(days: 5, hours: 1))
                    .millisecondsSinceEpoch ~/
                1000,
          ],
        );
      },
    );
    bool urgent() =>
        tester.widget<CompanyCard>(find.byType(CompanyCard)).urgent;
    expect(urgent(), isFalse);

    await tester.tap(find.byTooltip('設定'));
    await settle(tester);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byTooltip('増やす'));
      await tester.pump();
    }
    expect(find.text('6日以内の予定'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(urgent(), isTrue);

    await closeApp(tester, db);
  });
}
