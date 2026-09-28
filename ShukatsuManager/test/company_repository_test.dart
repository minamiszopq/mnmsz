import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shukatsu_manager/data/company_draft.dart';
import 'package:shukatsu_manager/data/company_repository.dart';
import 'package:shukatsu_manager/data/database.dart';

void main() {
  late AppDatabase db;
  late CompanyRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CompanyRepository(db);
  });
  tearDown(() => db.close());

  Future<int> statusId(String name) async =>
      (await db.select(db.statuses).get()).firstWhere((s) => s.name == name).id;

  test('新規保存 → 読み込みで内容が一致し、メモがログに入る', () async {
    final draft = CompanyDraft(
      name: ' 株式会社テスト ',
      statusId: await repo.defaultStatusId(),
      industryIds: {1, 3},
      mypageUrl: 'https://example.com',
      events: [
        EventDraft(
          type: EventType.deadline,
          title: 'ES提出',
          startsAt: DateTime(2026, 10, 1, 12),
        ),
      ],
      useCustomReminders: true,
      reminderMinutes: {1440, 60},
      memo: '志望動機メモ',
    );
    final id = await repo.saveDraft(draft);
    final loaded = await repo.loadDraft(id);
    expect(loaded.name, '株式会社テスト');
    expect(loaded.industryIds, {1, 3});
    expect(loaded.events.single.title, 'ES提出');
    expect(loaded.reminderMinutes, {1440, 60});
    final logs = await db.select(db.logs).get();
    expect(logs.single.body, '志望動機メモ');
  });

  test('編集で状態が変わると状態変更ログが記録され、予定は置き換わる', () async {
    final id = await repo.saveDraft(
      CompanyDraft(
        name: 'A社',
        statusId: await statusId('エントリー'),
        events: [
          EventDraft(type: EventType.deadline, startsAt: DateTime(2026, 10)),
        ],
      ),
    );
    final draft = await repo.loadDraft(id)
      ..statusId = await statusId('一次面接')
      ..events = []
      ..useCustomReminders = false
      ..reminderMinutes = {60};
    await repo.saveDraft(draft, id: id);

    final log = (await db.select(db.logs).get()).single;
    expect(log.kind, LogKind.statusChange);
    expect((log.fromStatus, log.toStatus), ('エントリー', '一次面接'));
    expect(await db.select(db.events).get(), isEmpty);
    expect(await db.select(db.companyReminders).get(), isEmpty);
  });

  test('状態の追加は同じ分類の末尾に入る', () async {
    await repo.addStatus('三次面接', StatusCategory.inProgress);
    final names = (await repo.watchStatuses().first).map((s) => s.name);
    expect(names, [
      'エントリー',
      '書類選考',
      '一次面接',
      '二次面接',
      '最終面接',
      '三次面接',
      '内定',
      'お祈り',
      '辞退',
    ]);
  });

  test('業界の追加は同名があれば既存を返す', () async {
    final a = await repo.addIndustry('ゲーム');
    expect(await repo.addIndustry('ゲーム'), a);
    expect(await repo.addIndustry('商社'), 3);
  });

  test('normalizeUrl', () {
    expect(normalizeUrl(''), '');
    expect(normalizeUrl('example.com/mypage'), 'https://example.com/mypage');
    expect(normalizeUrl('http://a.jp'), 'http://a.jp');
    expect(normalizeUrl('ftp://a.jp'), isNull);
    expect(normalizeUrl('あいう'), isNull);
  });

  test('changeStatus は変化があるときだけログを残す', () async {
    final id = await repo.saveDraft(
      CompanyDraft(name: 'B社', statusId: await statusId('エントリー')),
    );
    await repo.changeStatus(id, await statusId('エントリー'));
    expect(await db.select(db.logs).get(), isEmpty);
    await repo.changeStatus(id, await statusId('内定'));
    final detail = (await repo.fetchDetail(id))!;
    expect(detail.status.name, '内定');
    expect(detail.logs.single.toStatus, '内定');
  });

  test('メモの追加・編集・削除', () async {
    final id = await repo.saveDraft(
      CompanyDraft(name: 'C社', statusId: await repo.defaultStatusId()),
    );
    await repo.addMemo(id, '  一次面接の振り返り ');
    final log = (await repo.fetchDetail(id))!.logs.single;
    expect(log.body, '一次面接の振り返り');
    await repo.updateMemo(log.id, '更新');
    expect((await repo.fetchDetail(id))!.logs.single.body, '更新');
    await repo.deleteLog(log.id);
    expect((await repo.fetchDetail(id))!.logs, isEmpty);
  });

  test('ソフトデリート → 復元 → 物理削除', () async {
    final id = await repo.saveDraft(
      CompanyDraft(name: 'D社', statusId: await repo.defaultStatusId()),
    );
    await repo.softDelete(id);
    expect(await repo.fetchSummaries(), isEmpty);
    expect(await repo.fetchDetail(id), isNull);

    await repo.restore(id);
    expect(await repo.fetchSummaries(), hasLength(1));

    await repo.softDelete(id);
    expect(await repo.purgeDeleted(), 1);
    expect(await db.select(db.companies).get(), isEmpty);
  });
}
