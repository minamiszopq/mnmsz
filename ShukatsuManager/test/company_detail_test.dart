import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shukatsu_manager/data/sample_data.dart';
import 'package:shukatsu_manager/features/company_detail/company_detail_screen.dart';
import 'package:shukatsu_manager/features/home/home_screen.dart';

import 'helpers.dart';

void main() {
  testWidgets('詳細: 状態変更がログに残り、メモを追加できる', (tester) async {
    final db = await pumpApp(tester, seed: insertSampleData);

    await tester.tap(find.text('テックフロンティア'));
    await settle(tester);
    expect(find.byType(CompanyDetailScreen), findsOneWidget);

    await tester.tap(find.text('一次面接'));
    await settle(tester);
    await tester.tap(find.text('二次面接'));
    await settle(tester);
    expect(find.text('一次面接 → 二次面接'), findsOneWidget);

    await tester.tap(find.text('メモを追加'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, '逆質問を3つ用意する');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await settle(tester);
    expect(find.text('逆質問を3つ用意する'), findsOneWidget);

    await closeApp(tester, db);
  });

  testWidgets('詳細: 削除すると一覧から消え、元に戻すで復活する', (tester) async {
    final db = await pumpApp(tester, seed: insertSampleData);

    await tester.tap(find.text('みらい銀行'));
    await settle(tester);
    await tester.tap(find.byTooltip('削除'));
    await settle(tester);

    expect(find.byType(CompanyDetailScreen), findsNothing);
    expect(find.text('「みらい銀行」を削除しました'), findsOneWidget);
    expect(find.widgetWithText(CompanyCard, 'みらい銀行'), findsNothing);

    await tester.tap(find.text('元に戻す'));
    await settle(tester);
    expect(find.widgetWithText(CompanyCard, 'みらい銀行'), findsOneWidget);

    await closeApp(tester, db);
  });
}
