import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shukatsu_manager/data/company_draft.dart';
import 'package:shukatsu_manager/data/company_repository.dart';
import 'package:shukatsu_manager/data/database.dart';
import 'package:shukatsu_manager/notifications/reminder_planner.dart';
import 'package:shukatsu_manager/notifications/reminder_scheduler.dart';
import 'package:shukatsu_manager/notifications/reminder_sync.dart';
import 'package:shukatsu_manager/settings/settings.dart';

final now = DateTime(2026, 9, 21, 12);

ReminderSource src(
  int id,
  Duration until, {
  bool custom = false,
  Set<int> minutes = const {},
  String? title,
}) => ReminderSource(
  event: Event(
    id: id,
    companyId: id,
    type: EventType.interview,
    title: title,
    startsAt: now.add(until),
  ),
  companyName: '企業$id',
  useCustomReminders: custom,
  customMinutes: minutes,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting('ja'));

  group('planReminders', () {
    test('共通設定で通知を作り、過去になるものは除く', () {
      final plan = planReminders(
        sources: [src(1, const Duration(hours: 5), title: '一次面接')],
        defaultMinutes: {1440, 180},
        now: now,
      );
      expect(plan, hasLength(1));
      expect(plan.single.fireAt, now.add(const Duration(hours: 2)));
      expect(plan.single.title, '企業1:一次面接(3時間前)');
      expect(plan.single.body, '9/21(月) 17:00 一次面接');
      expect(plan.single.companyId, 1);
    });

    test('企業ごとの設定が共通設定より優先される(空なら通知しない)', () {
      final plan = planReminders(
        sources: [
          src(1, const Duration(days: 10), custom: true, minutes: {10080}),
          src(2, const Duration(days: 10), custom: true),
        ],
        defaultMinutes: {1440, 60},
        now: now,
      );
      expect(plan.map((r) => r.companyId), [1]);
      expect(plan.single.fireAt, now.add(const Duration(days: 3)));
    });

    test('発火が近い順に上限件数まで、IDは連番', () {
      final plan = planReminders(
        sources: [for (var i = 1; i <= 50; i++) src(i, Duration(days: 51 - i))],
        defaultMinutes: {1440, 60},
        now: now,
        limit: 60,
      );
      expect(plan, hasLength(60));
      expect(plan.map((r) => r.id), List.generate(60, (i) => i));
      for (var i = 1; i < plan.length; i++) {
        expect(plan[i].fireAt.isBefore(plan[i - 1].fireAt), isFalse);
      }
      // 最も近い予定(企業50, 1日後)の1時間前が先頭
      expect(plan.first.companyId, 50);
    });
  });

  group('DB連携', () {
    late AppDatabase db;
    late CompanyRepository repo;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = CompanyRepository(db);
    });
    tearDown(() => db.close());

    Future<int> status(String name) async =>
        (await db.select(db.statuses).get())
            .firstWhere((s) => s.name == name)
            .id;

    Future<int> company(String name, String statusName, Duration until) async =>
        repo.saveDraft(
          CompanyDraft(
            name: name,
            statusId: await status(statusName),
            events: [
              EventDraft(
                type: EventType.deadline,
                startsAt: DateTime.now().add(until),
              ),
            ],
          ),
        );

    test('削除済み・お祈り・辞退・過去の予定は通知対象外', () async {
      await company('対象', '一次面接', const Duration(days: 2));
      await company('内定も対象', '内定', const Duration(days: 2));
      await company('お祈り', 'お祈り', const Duration(days: 2));
      await company('辞退', '辞退', const Duration(days: 2));
      await company('過去', '一次面接', const Duration(days: -1));
      await repo.softDelete(
        await company('削除', '一次面接', const Duration(days: 2)),
      );

      final names = (await repo.fetchReminderSources(DateTime.now()))
          .map((s) => s.companyName);
      expect(names, unorderedEquals(['対象', '内定も対象']));
    });

    test('ReminderSync: データ変更で再予約、通知オフで全取消、許可は一度だけ', () async {
      final scheduler = _CountingScheduler();
      var settings = const AppSettings();
      var asked = false;
      final sync = ReminderSync(
        repository: repo,
        scheduler: scheduler,
        readSettings: () => settings,
        permissionAsked: () => asked,
        markPermissionAsked: () async => asked = true,
        debounce: Duration.zero,
      );

      await sync.syncNow();
      expect(scheduler.calls.last, isEmpty);
      expect(scheduler.permissionRequests, 0, reason: '通知が不要なうちは許可を求めない');

      await company('A社', '一次面接', const Duration(days: 3));
      await sync.syncNow();
      expect(scheduler.calls.last, hasLength(2)); // 前日・1時間前
      expect(scheduler.permissionRequests, 1);

      await company('B社', '一次面接', const Duration(days: 3));
      await sync.syncNow();
      expect(scheduler.calls.last, hasLength(4));
      expect(scheduler.permissionRequests, 1);

      settings = settings.copyWith(notificationsEnabled: false);
      await sync.syncNow();
      expect(scheduler.calls.last, isEmpty);
    });

    test('ReminderSync.start: DB変更を検知して自動で再予約する', () async {
      final scheduler = _CountingScheduler();
      final sync = ReminderSync(
        repository: repo,
        scheduler: scheduler,
        readSettings: () => const AppSettings(),
        permissionAsked: () => true,
        markPermissionAsked: () async {},
        debounce: const Duration(milliseconds: 10),
      )..start();
      addTearDown(sync.dispose);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      final before = scheduler.calls.length;
      await company('C社', '一次面接', const Duration(days: 3));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(scheduler.calls.length, greaterThan(before));
      expect(scheduler.calls.last, hasLength(2));
    });
  });
}

class _CountingScheduler extends NoopReminderScheduler {
  int permissionRequests = 0;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return true;
  }
}
