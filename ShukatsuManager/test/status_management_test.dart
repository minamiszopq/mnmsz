import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shukatsu_manager/data/company_draft.dart';
import 'package:shukatsu_manager/data/company_repository.dart';
import 'package:shukatsu_manager/data/database.dart';
import 'package:shukatsu_manager/data/sample_data.dart';
import 'package:shukatsu_manager/features/statuses/status_management_screen.dart';

import 'helpers.dart';

void main() {
  group('リポジトリ', () {
    late AppDatabase db;
    late CompanyRepository repo;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = CompanyRepository(db);
    });
    tearDown(() => db.close());

    Future<List<String>> names() async =>
        (await repo.watchStatuses().first).map((s) => s.name).toList();
    Future<int> id(String name) async => (await db.select(db.statuses).get())
        .firstWhere((s) => s.name == name)
        .id;

    test('名前・分類の変更', () async {
      await repo.updateStatus(await id('お祈り'), '不合格', StatusCategory.closed);
      expect(await names(), contains('不合格'));
    });

    test('並べ替え', () async {
      final ids = [for (final s in await repo.watchStatuses().first) s.id];
      await repo.reorderStatuses([ids.last, ...ids.take(ids.length - 1)]);
      expect((await names()).first, '辞退');
    });

    test('使用中の状態は移動先へ移し、履歴を残して削除', () async {
      final c = await repo.saveDraft(
        CompanyDraft(name: 'A社', statusId: await id('二次面接')),
      );
      final deleted = await repo.saveDraft(
        CompanyDraft(name: '削除済み', statusId: await id('二次面接')),
      );
      await repo.softDelete(deleted);
      expect((await repo.watchStatusUsage().first)[await id('二次面接')], 2);

      expect(() async => repo.deleteStatus(await id('二次面接')), throwsStateError);

      await repo.deleteStatus(await id('二次面接'), moveTo: await id('最終面接'));
      expect(await names(), isNot(contains('二次面接')));
      expect((await repo.fetchDetail(c))!.status.name, '最終面接');
      final logs = await db.select(db.logs).get();
      expect(logs.single.companyId, c, reason: '削除済み企業には履歴を残さない');
      expect((logs.single.fromStatus, logs.single.toStatus), ('二次面接', '最終面接'));
    });

    test('未使用の状態はそのまま削除', () async {
      await repo.deleteStatus(await id('辞退'));
      expect(await names(), isNot(contains('辞退')));
    });
  });

  testWidgets('管理画面: 名前変更・同名チェック・使用中の削除', (tester) async {
    final db = await pumpApp(tester, seed: insertSampleData);
    await tester.tap(find.byTooltip('設定'));
    await settle(tester);
    await tester.ensureVisible(find.text('選考状態の管理'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('選考状態の管理'));
    await settle(tester);
    expect(find.byType(StatusManagementScreen), findsOneWidget);
    expect(find.text('選考中・1社'), findsWidgets);

    // 名前変更: 同名は保存できない
    await tester.tap(find.text('お祈り'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), '辞退');
    await tester.pump();
    expect(find.text('同じ名前の状態があります'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '不合格');
    await tester.pump();
    await tester.tap(find.text('保存'));
    await settle(tester);
    expect(find.text('不合格'), findsOneWidget);

    // 使用中(サンプルの「一次面接」は1社)を削除 → 移動先は同じ分類の先頭
    await tester.tap(find.byTooltip('「一次面接」を削除'));
    await settle(tester);
    expect(find.textContaining('1社あります'), findsOneWidget);
    await tester.tap(find.text('削除'));
    await settle(tester);
    expect(find.text('一次面接'), findsNothing);

    final moved = await tester.runAsync(
      () => (db.select(
        db.companies,
      )..where((c) => c.name.equals('テックフロンティア'))).getSingle(),
    );
    final status = await tester.runAsync(
      () => (db.select(
        db.statuses,
      )..where((s) => s.id.equals(moved!.statusId))).getSingle(),
    );
    expect(status!.name, '書類選考');

    await closeApp(tester, db);
  });

  testWidgets('管理画面: ドラッグで並べ替え', (tester) async {
    final db = await pumpApp(tester);
    await tester.tap(find.byTooltip('設定'));
    await settle(tester);
    await tester.ensureVisible(find.text('選考状態の管理'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('選考状態の管理'));
    await settle(tester);

    final handle = find.byIcon(Icons.drag_handle).first;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 80)); // 1行ぶん下へ
    await tester.pump();
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();
    await gesture.up();
    await settle(tester);

    final order = await tester.runAsync(
      () async => [
        for (final s in await (db.select(
          db.statuses,
        )..orderBy([(s) => OrderingTerm.asc(s.sortOrder)])).get())
          s.name,
      ],
    );
    expect(order!.first, '書類選考');
    expect(order.indexOf('エントリー'), greaterThan(0));

    await closeApp(tester, db);
  });
}
