import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shukatsu_manager/data/database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('初期データが投入される', () async {
    final statuses = await db.select(db.statuses).get();
    expect(statuses.map((s) => s.name), contains('辞退'));
    expect((await db.select(db.industries).get()), hasLength(10));
  });

  test('企業削除で予定・ログがカスケード削除される', () async {
    final cid = await db
        .into(db.companies)
        .insert(CompaniesCompanion.insert(name: 'テスト株式会社', statusId: 1));
    await db
        .into(db.events)
        .insert(
          EventsCompanion.insert(
            companyId: cid,
            type: EventType.deadline,
            startsAt: DateTime(2026, 10, 1),
          ),
        );
    await db
        .into(db.logs)
        .insert(
          LogsCompanion.insert(
            companyId: cid,
            kind: LogKind.memo,
            body: const Value('ES提出'),
          ),
        );
    await (db.delete(db.companies)..where((c) => c.id.equals(cid))).go();
    expect(await db.select(db.events).get(), isEmpty);
    expect(await db.select(db.logs).get(), isEmpty);
  });
}
