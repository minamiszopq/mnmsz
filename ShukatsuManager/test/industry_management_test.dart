import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shukatsu_manager/data/company_repository.dart';
import 'package:shukatsu_manager/data/database.dart';
import 'package:shukatsu_manager/data/sample_data.dart';
import 'package:shukatsu_manager/features/industries/industry_management_screen.dart';

import 'helpers.dart';

void main() {
  test('v1 → v2 マイグレーション: 既存データを保ち、並び順は登録順', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(File('test/fixtures/schema_v1.sql').readAsStringSync());
          raw.execute('''
            INSERT INTO statuses (name, category, sort_order) VALUES ('エントリー', 0, 0);
            INSERT INTO industries (name) VALUES ('商社'), ('IT'), ('金融');
            INSERT INTO companies (name, status_id) VALUES ('旧データ社', 1);
            INSERT INTO company_industries VALUES (1, 2);
            PRAGMA user_version = 1;
          ''');
        },
      ),
    );
    addTearDown(db.close);
    final repo = CompanyRepository(db);

    final industries = await repo.watchIndustries().first;
    expect(industries.map((i) => (i.name, i.sortOrder)), [
      ('商社', 1),
      ('IT', 2),
      ('金融', 3),
    ]);
    expect((await repo.fetchSummaries()).single.industries, ['IT']);

    // 追加は末尾に入る
    await repo.addIndustry('ゲーム');
    expect((await repo.watchIndustries().first).last.name, 'ゲーム');
  });

  group('リポジトリ', () {
    late AppDatabase db;
    late CompanyRepository repo;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = CompanyRepository(db);
    });
    tearDown(() => db.close());

    test('並べ替えが一覧・企業の業界表示の順に反映される', () async {
      await insertSampleData(db);
      final ids = [for (final i in await repo.watchIndustries().first) i.id];
      await repo.reorderIndustries(ids.reversed.toList());
      expect((await repo.watchIndustries().first).first.name, '官公庁・公社');

      final consulting = (await repo.fetchSummaries()).firstWhere(
        (s) => s.company.name == 'グローバルコンサルティング',
      );
      expect(consulting.industries, ['コンサル', 'IT・通信']);
    });

    test('企業数は削除済みを数えず、業界削除で紐付けだけ外れる', () async {
      await insertSampleData(db);
      final usage = await repo.watchIndustryUsage().first;
      expect(usage[1], 2); // IT・通信: テックフロンティア + コンサル

      final tech = (await repo.fetchSummaries()).firstWhere(
        (s) => s.company.name == 'テックフロンティア',
      );
      await repo.softDelete(tech.company.id);
      expect((await repo.watchIndustryUsage().first)[1], 1);

      await repo.deleteIndustry(1);
      expect(await repo.fetchSummaries(), hasLength(5));
      expect(
        (await repo.fetchSummaries()).expand((s) => s.industries),
        isNot(contains('IT・通信')),
      );
    });
  });

  testWidgets('管理画面: 名前変更・同名チェック・削除・並べ替え', (tester) async {
    final db = await pumpApp(tester, seed: insertSampleData);
    await tester.tap(find.byTooltip('設定'));
    await settle(tester);
    await tester.ensureVisible(find.text('業界の管理'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('業界の管理'));
    await settle(tester);
    expect(find.byType(IndustryManagementScreen), findsOneWidget);
    expect(find.text('2社'), findsOneWidget);

    await tester.tap(find.text('商社'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), '金融');
    await tester.pump();
    expect(find.text('同じ名前の業界があります'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '総合商社');
    await tester.pump();
    await tester.tap(find.text('保存'));
    await settle(tester);
    expect(find.text('総合商社'), findsOneWidget);

    await tester.tap(find.byTooltip('「IT・通信」を削除'));
    await settle(tester);
    expect(find.text('2社からこの業界が外れます。企業は削除されません。'), findsOneWidget);
    await tester.tap(find.text('削除'));
    await settle(tester);
    expect(find.text('IT・通信'), findsNothing);

    // 先頭(メーカー)を1行下へ
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.drag_handle).first),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();
    await gesture.up();
    await settle(tester);

    final order = await tester.runAsync(
      () async => [
        for (final i in await (db.select(
          db.industries,
        )..orderBy([(i) => OrderingTerm.asc(i.sortOrder)])).get())
          i.name,
      ],
    );
    expect(order!.take(2), ['総合商社', 'メーカー']);

    await closeApp(tester, db);
  });
}
