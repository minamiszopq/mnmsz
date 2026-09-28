import 'package:drift/drift.dart';

import 'database.dart';

/// 開発用のサンプル企業を投入する(デバッグビルドのみで使用)
Future<void> insertSampleData(AppDatabase db) async {
  final now = DateTime.now();
  final statuses = {
    for (final s in await db.select(db.statuses).get()) s.name: s.id,
  };
  final samples = [
    ('サンプル商事', 'エントリー', [3], const Duration(days: 1, hours: 3)),
    ('テックフロンティア', '一次面接', [1], const Duration(days: 5)),
    ('みらい銀行', '書類選考', [4], const Duration(hours: 20)),
    ('グローバルコンサルティング', '最終面接', [5, 1], const Duration(days: 12)),
    ('日本ものづくり工業', '内定', [2], null),
    ('あおぞら広告', 'お祈り', [6], null),
  ];
  await db.transaction(() async {
    for (final (name, status, industryIds, until) in samples) {
      final id = await db
          .into(db.companies)
          .insert(
            CompaniesCompanion.insert(name: name, statusId: statuses[status]!),
          );
      for (final iid in industryIds) {
        await db
            .into(db.companyIndustries)
            .insert(
              CompanyIndustriesCompanion.insert(companyId: id, industryId: iid),
            );
      }
      if (until != null) {
        await db
            .into(db.events)
            .insert(
              EventsCompanion.insert(
                companyId: id,
                type: status == 'エントリー' || status == '書類選考'
                    ? EventType.deadline
                    : EventType.interview,
                title: Value(status == '書類選考' ? 'ES提出' : null),
                startsAt: now.add(until),
              ),
            );
      }
    }
  });
}
