import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shukatsu_manager/csv/csv_format.dart';
import 'package:shukatsu_manager/data/company_repository.dart';
import 'package:shukatsu_manager/data/database.dart';
import 'package:shukatsu_manager/data/sample_data.dart';
import 'package:shukatsu_manager/features/settings/csv_actions.dart';

void main() {
  setUpAll(() => initializeDateFormatting('ja'));

  group('DB 往復', () {
    late AppDatabase db1, db2;
    late CompanyRepository repo1, repo2;
    setUp(() {
      db1 = AppDatabase(NativeDatabase.memory());
      db2 = AppDatabase(NativeDatabase.memory());
      repo1 = CompanyRepository(db1);
      repo2 = CompanyRepository(db2);
    });
    tearDown(() async {
      await db1.close();
      await db2.close();
    });

    test('エクスポート → インポートで内容が一致する', () async {
      await insertSampleData(db1);
      final id = (await repo1.fetchSummaries()).first.company.id;
      await repo1.addMemo(id, 'ES本文\n2行目, カンマ "引用符" 入り');
      await repo1.changeStatus(id, 3);
      await repo1.addStatus('GD', StatusCategory.inProgress);
      final gdCompany = (await repo1.fetchSummaries())[1].company.id;
      final draft = await repo1.loadDraft(gdCompany)
        ..useCustomReminders = true
        ..reminderMinutes = {10080, 60}
        ..industryIds.add(await repo1.addIndustry('ゲーム'));
      await repo1.saveDraft(draft, id: gdCompany);
      await repo1.changeStatus(
        gdCompany,
        (await db1.select(db1.statuses).get())
            .firstWhere((s) => s.name == 'GD')
            .id,
      );
      final noReminder = await repo1.loadDraft(3)
        ..useCustomReminders = true
        ..reminderMinutes = {};
      await repo1.saveDraft(noReminder, id: 3);

      final csv = encodeCompaniesCsv(await repo1.fetchCsvCompanies());
      expect(csv.startsWith('﻿企業名,選考状態,'), isTrue);

      final parsed = parseCompaniesCsv(csv);
      expect(parsed.warnings, isEmpty);
      final r = await repo2.importCsvCompanies(
        parsed.companies,
        skipDuplicates: true,
      );
      expect(r.added, 6);

      expect(
        encodeCompaniesCsv(await repo2.fetchCsvCompanies()),
        csv,
        reason: 'インポート後に再エクスポートしても同じ内容になる',
      );
      final logs = await db2.select(db2.logs).get();
      expect(logs.where((l) => l.kind == LogKind.statusChange), hasLength(2));
      expect(
        logs.firstWhere((l) => l.kind == LogKind.memo).body,
        'ES本文\n2行目, カンマ "引用符" 入り',
      );
    });

    test('同名の企業: スキップ / すべて追加', () async {
      await insertSampleData(db1);
      final items = parseCompaniesCsv(
        encodeCompaniesCsv(await repo1.fetchCsvCompanies()),
      ).companies;
      await repo2.importCsvCompanies(
        items.take(2).toList(),
        skipDuplicates: true,
      );

      final skip = await repo2.importCsvCompanies(items, skipDuplicates: true);
      expect((skip.added, skip.skipped), (4, 2));
      final all = await repo2.importCsvCompanies(items, skipDuplicates: false);
      expect((all.added, all.skipped), (6, 0));
      expect(await repo2.fetchSummaries(), hasLength(12));
    });

    test('未知の選考状態・業界は追加される', () async {
      final parsed = parseCompaniesCsv(
        '会社名,ステータス,業種\nA社,三次面接,"ゲーム\n商社"\nB社,,\n',
      );
      await repo2.importCsvCompanies(parsed.companies, skipDuplicates: true);
      final summaries = await repo2.fetchSummaries();
      final a = summaries.firstWhere((s) => s.company.name == 'A社');
      expect(a.status.name, '三次面接');
      expect(a.status.category, StatusCategory.inProgress);
      expect(a.industries, ['商社', 'ゲーム']);
      final b = summaries.firstWhere((s) => s.company.name == 'B社');
      expect(b.status.name, 'エントリー');
    });
  });

  group('parseCompaniesCsv', () {
    test('手作りの表: 別名の列・時刻なし・種類なし・日時なしメモ', () {
      final r = parseCompaniesCsv(
        'ステータス,会社名,締切,備考,URL,リマインド\n'
        '書類選考,A社,"2026/10/1 ES提出\n2026-10-05 14:30 面接 一次",'
        '"志望動機\n長文",a.example.com/login,なし\n'
        ',,,,,\n'
        '内定,,,,,\n'
        'C社,C社,あした,,ftp://x,毎日\n',
      );
      expect(r.companies.map((c) => c.name), ['A社', 'C社']);
      final a = r.companies.first;
      expect(a.statusName, '書類選考');
      expect(a.events[0].startsAt, DateTime(2026, 10, 1, 12));
      expect(a.events[0].type, EventType.other);
      expect(a.events[0].title, 'ES提出');
      expect(a.events[1].startsAt, DateTime(2026, 10, 5, 14, 30));
      expect(a.events[1].type, EventType.interview);
      expect(a.events[1].title, '一次');
      expect(a.logs.single.body, '志望動機\n長文');
      expect(a.logs.single.createdAt, isNull);
      expect(a.mypageUrl, 'https://a.example.com/login');
      expect(a.reminderMinutes, isEmpty);
      expect(r.companies[1].reminderMinutes, isEmpty);
      expect(r.warnings, [
        '4行目: 企業名が空のため読み飛ばしました',
        '5行目: 予定「あした」の日時を読み取れませんでした',
        '5行目: 通知設定「毎日」は使えないため無視しました',
        '5行目: URLの形式が正しくないため空にしました',
      ]);
    });

    test('企業名の列がなければエラー', () {
      expect(
        () => parseCompaniesCsv('名前だけ,メモ\nA,B\n'),
        throwsA(isA<CsvFormatException>()),
      );
    });

    test('ログ: 日時で区切り、続く行は同じメモに含める', () {
      final logs = parseCompaniesCsv(
        '企業名,メモ\n'
        'A社,"[2026/09/01 10:00] 1件目\n続き\n[2026/09/02 11:00] 【状態変更】エントリー → 一次面接"\n',
      ).companies.single.logs;
      expect(logs, hasLength(2));
      expect(logs[0].body, '1件目\n続き');
      expect(logs[0].createdAt, DateTime(2026, 9, 1, 10));
      expect(logs[1].kind, LogKind.statusChange);
      expect((logs[1].fromStatus, logs[1].toStatus), ('エントリー', '一次面接'));
    });
  });

  testWidgets('取り込み確認: 同名があるときだけスキップを選べる', (tester) async {
    ImportChoice? choice;
    final parsed = CsvParseResult([CsvCompany(name: 'A')], const ['注意1']);
    Future<void> open(int dups) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async =>
                  choice = await showImportPreview(context, parsed, dups),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    await open(0);
    expect(find.text('同名はスキップ'), findsNothing);
    expect(find.text('・注意1'), findsOneWidget);
    await tester.tap(find.text('取り込む'));
    await tester.pumpAndSettle();
    expect(choice, ImportChoice.addAll);

    await open(1);
    await tester.tap(find.text('同名はスキップ'));
    await tester.pumpAndSettle();
    expect(choice, ImportChoice.skipDuplicates);
  });
}
