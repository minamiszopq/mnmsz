import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shukatsu_manager/data/sample_data.dart';
import 'package:shukatsu_manager/features/company_form/company_form_screen.dart';
import 'package:shukatsu_manager/features/home/home_screen.dart';

import 'helpers.dart';

void main() {
  testWidgets('サンプルデータがカード表示され、タブで絞り込める', (tester) async {
    final db = await pumpApp(tester, seed: insertSampleData);

    expect(find.byType(CompanyCard), findsWidgets);
    expect(find.text('みらい銀行'), findsOneWidget);
    expect(find.text('すべて 6'), findsOneWidget);

    await tester.tap(find.text('内定 1'));
    await tester.pumpAndSettle();
    expect(find.text('日本ものづくり工業'), findsOneWidget);
    expect(find.text('みらい銀行'), findsNothing);

    await closeApp(tester, db);
  });

  testWidgets('新規登録: 企業名必須チェック → 保存すると一覧に出る', (tester) async {
    final db = await pumpApp(tester);

    await tester.tap(find.text('企業を追加'));
    await settle(tester);
    expect(find.byType(CompanyFormScreen), findsOneWidget);

    await tester.tap(find.text('保存'));
    await settle(tester);
    expect(find.text('企業名を入力してください'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '新規テスト株式会社');
    await tester.tap(find.text('商社'));
    await tester.pump();
    await tester.tap(find.text('保存'));
    await settle(tester);

    expect(find.byType(CompanyFormScreen), findsNothing);
    expect(find.text('新規テスト株式会社'), findsOneWidget);
    expect(find.text('商社'), findsOneWidget);

    await closeApp(tester, db);
  });
}
