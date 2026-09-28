import 'package:drift/drift.dart';

import '../csv/csv_format.dart';
import '../notifications/reminder_planner.dart';
import 'company_draft.dart';
import 'database.dart';

/// 一覧カード表示用にまとめた企業情報
class CompanySummary {
  const CompanySummary({
    required this.company,
    required this.status,
    required this.industries,
    this.nextEvent,
  });

  final Company company;
  final Status status;
  final List<String> industries;

  /// 現在以降で最も近い予定。なければ null。
  final Event? nextEvent;
}

/// 詳細画面用の企業情報一式
class CompanyDetail {
  const CompanyDetail({
    required this.company,
    required this.status,
    required this.industries,
    required this.events,
    required this.reminderMinutes,
    required this.logs,
  });

  final Company company;
  final Status status;
  final List<String> industries;

  /// 日時昇順(過去の予定も含む)
  final List<Event> events;
  final List<int> reminderMinutes;

  /// 新しい順
  final List<Log> logs;
}

class CompanyRepository {
  CompanyRepository(this._db);

  final AppDatabase _db;

  /// 関連テーブルのいずれかが更新されるたびに一覧を再取得する
  Stream<List<CompanySummary>> watchSummaries() async* {
    final tables = TableUpdateQuery.onAllTables([
      _db.companies,
      _db.statuses,
      _db.industries,
      _db.companyIndustries,
      _db.events,
    ]);
    yield await fetchSummaries();
    await for (final _ in _db.tableUpdates(tables)) {
      yield await fetchSummaries();
    }
  }

  Future<List<CompanySummary>> fetchSummaries({DateTime? now}) async {
    final at = now ?? DateTime.now();

    final rows = await (_db.select(_db.companies).join([
      innerJoin(
        _db.statuses,
        _db.statuses.id.equalsExp(_db.companies.statusId),
      ),
    ])..where(_db.companies.deletedAt.isNull())).get();

    final industryRows = await (_db.select(_db.companyIndustries).join([
      innerJoin(
        _db.industries,
        _db.industries.id.equalsExp(_db.companyIndustries.industryId),
      ),
    ])..orderBy([OrderingTerm.asc(_db.industries.sortOrder)])).get();
    final industriesByCompany = <int, List<String>>{};
    for (final r in industryRows) {
      industriesByCompany
          .putIfAbsent(r.readTable(_db.companyIndustries).companyId, () => [])
          .add(r.readTable(_db.industries).name);
    }

    final upcoming =
        await (_db.select(_db.events)
              ..where((e) => e.startsAt.isBiggerOrEqualValue(at))
              ..orderBy([(e) => OrderingTerm.asc(e.startsAt)]))
            .get();
    final nextByCompany = <int, Event>{};
    for (final e in upcoming) {
      nextByCompany.putIfAbsent(e.companyId, () => e);
    }

    return [
      for (final r in rows)
        CompanySummary(
          company: r.readTable(_db.companies),
          status: r.readTable(_db.statuses),
          industries: industriesByCompany[r.readTable(_db.companies).id] ?? [],
          nextEvent: nextByCompany[r.readTable(_db.companies).id],
        ),
    ];
  }

  Stream<List<Status>> watchStatuses() => (_db.select(
    _db.statuses,
  )..orderBy([(s) => OrderingTerm.asc(s.sortOrder)])).watch();

  Stream<List<Industry>> watchIndustries() =>
      (_db.select(_db.industries)..orderBy([
            (i) => OrderingTerm.asc(i.sortOrder),
            (i) => OrderingTerm.asc(i.id),
          ]))
          .watch();

  /// 同名があればその id を返す
  Future<int> addIndustry(String name) async {
    final existing = await (_db.select(
      _db.industries,
    )..where((i) => i.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    final max = _db.industries.sortOrder.max();
    final last = await (_db.selectOnly(
      _db.industries,
    )..addColumns([max])).map((r) => r.read(max)).getSingle();
    return _db
        .into(_db.industries)
        .insert(
          IndustriesCompanion.insert(
            name: name,
            sortOrder: Value((last ?? -1) + 1),
          ),
        );
  }

  /// 同じカテゴリの末尾に挿入し、後続の並び順をずらす
  Future<int> addStatus(String name, StatusCategory category) {
    return _db.transaction(() async {
      final all = await (_db.select(
        _db.statuses,
      )..orderBy([(s) => OrderingTerm.asc(s.sortOrder)])).get();
      final sameCategory = all.where((s) => s.category == category);
      final before = all.where((s) => s.category.index <= category.index);
      final order = sameCategory.isNotEmpty
          ? sameCategory.last.sortOrder + 1
          : (before.isEmpty ? 0 : before.last.sortOrder + 1);
      await _db.customUpdate(
        'UPDATE statuses SET sort_order = sort_order + 1 WHERE sort_order >= ?',
        variables: [Variable.withInt(order)],
        updates: {_db.statuses},
      );
      return _db
          .into(_db.statuses)
          .insert(
            StatusesCompanion.insert(
              name: name,
              category: category,
              sortOrder: order,
            ),
          );
    });
  }

  Future<int> defaultStatusId() async {
    final first =
        await (_db.select(_db.statuses)
              ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)])
              ..limit(1))
            .getSingle();
    return first.id;
  }

  Future<CompanyDraft> loadDraft(int id) async {
    final c = await (_db.select(
      _db.companies,
    )..where((c) => c.id.equals(id))).getSingle();
    final industries = await (_db.select(
      _db.companyIndustries,
    )..where((ci) => ci.companyId.equals(id))).get();
    final events =
        await (_db.select(_db.events)
              ..where((e) => e.companyId.equals(id))
              ..orderBy([(e) => OrderingTerm.asc(e.startsAt)]))
            .get();
    final reminders = await (_db.select(
      _db.companyReminders,
    )..where((r) => r.companyId.equals(id))).get();
    return CompanyDraft(
      name: c.name,
      statusId: c.statusId,
      industryIds: {for (final i in industries) i.industryId},
      mypageId: c.mypageId ?? '',
      mypageUrl: c.mypageUrl ?? '',
      events: [
        for (final e in events)
          EventDraft(type: e.type, title: e.title ?? '', startsAt: e.startsAt),
      ],
      useCustomReminders: c.useCustomReminders,
      reminderMinutes: {for (final r in reminders) r.minutesBefore},
    );
  }

  /// [id] が null なら新規作成。状態が変わった場合はログに記録する。
  Future<int> saveDraft(CompanyDraft d, {int? id}) {
    return _db.transaction(() async {
      final now = DateTime.now();
      final values = CompaniesCompanion(
        name: Value(d.name.trim()),
        statusId: Value(d.statusId),
        mypageId: Value(_blankToNull(d.mypageId)),
        mypageUrl: Value(_blankToNull(d.mypageUrl)),
        useCustomReminders: Value(d.useCustomReminders),
        updatedAt: Value(now),
      );

      final int companyId;
      if (id == null) {
        companyId = await _db.into(_db.companies).insert(values);
        if (d.memo.trim().isNotEmpty) {
          await _db
              .into(_db.logs)
              .insert(
                LogsCompanion.insert(
                  companyId: companyId,
                  kind: LogKind.memo,
                  body: Value(d.memo.trim()),
                ),
              );
        }
      } else {
        companyId = id;
        final before = await (_db.select(
          _db.companies,
        )..where((c) => c.id.equals(id))).getSingle();
        await (_db.update(
          _db.companies,
        )..where((c) => c.id.equals(id))).write(values);
        if (before.statusId != d.statusId) {
          await _logStatusChange(id, before.statusId, d.statusId);
        }
        await (_db.delete(
          _db.companyIndustries,
        )..where((t) => t.companyId.equals(id))).go();
        await (_db.delete(
          _db.events,
        )..where((t) => t.companyId.equals(id))).go();
        await (_db.delete(
          _db.companyReminders,
        )..where((t) => t.companyId.equals(id))).go();
      }

      await _db.batch(
        (b) => _insertChildren(
          b,
          companyId,
          industryIds: d.industryIds,
          events: d.events,
          reminderMinutes: d.useCustomReminders ? d.reminderMinutes : const {},
        ),
      );
      return companyId;
    });
  }

  /// 企業に紐づく業界・予定・通知設定をまとめて登録する
  void _insertChildren(
    Batch b,
    int companyId, {
    required Iterable<int> industryIds,
    required List<EventDraft> events,
    required Iterable<int> reminderMinutes,
  }) {
    b.insertAll(_db.companyIndustries, [
      for (final iid in industryIds)
        CompanyIndustriesCompanion.insert(
          companyId: companyId,
          industryId: iid,
        ),
    ]);
    b.insertAll(_db.events, [
      for (final e in events)
        EventsCompanion.insert(
          companyId: companyId,
          type: e.type,
          title: Value(_blankToNull(e.title)),
          startsAt: e.startsAt,
        ),
    ]);
    b.insertAll(_db.companyReminders, [
      for (final m in reminderMinutes)
        CompanyRemindersCompanion.insert(
          companyId: companyId,
          minutesBefore: m,
        ),
    ]);
  }

  static String? _blankToNull(String s) => s.trim().isEmpty ? null : s.trim();

  Future<void> _logStatusChange(int companyId, int fromId, int toId) async {
    final names = {
      for (final s in await (_db.select(
        _db.statuses,
      )..where((s) => s.id.isIn([fromId, toId]))).get())
        s.id: s.name,
    };
    await _db
        .into(_db.logs)
        .insert(
          LogsCompanion.insert(
            companyId: companyId,
            kind: LogKind.statusChange,
            fromStatus: Value(names[fromId]),
            toStatus: Value(names[toId]),
          ),
        );
  }

  /// 削除済み・存在しない場合は null を流す
  Stream<CompanyDetail?> watchDetail(int id) async* {
    final tables = TableUpdateQuery.onAllTables([
      _db.companies,
      _db.statuses,
      _db.industries,
      _db.companyIndustries,
      _db.events,
      _db.companyReminders,
      _db.logs,
    ]);
    yield await fetchDetail(id);
    await for (final _ in _db.tableUpdates(tables)) {
      yield await fetchDetail(id);
    }
  }

  Future<CompanyDetail?> fetchDetail(int id) async {
    final row =
        await (_db.select(_db.companies).join([
              innerJoin(
                _db.statuses,
                _db.statuses.id.equalsExp(_db.companies.statusId),
              ),
            ])..where(
              _db.companies.id.equals(id) & _db.companies.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (row == null) return null;

    final industries =
        await (_db.select(_db.companyIndustries).join([
                innerJoin(
                  _db.industries,
                  _db.industries.id.equalsExp(_db.companyIndustries.industryId),
                ),
              ])
              ..where(_db.companyIndustries.companyId.equals(id))
              ..orderBy([OrderingTerm.asc(_db.industries.sortOrder)]))
            .get();
    final events =
        await (_db.select(_db.events)
              ..where((e) => e.companyId.equals(id))
              ..orderBy([(e) => OrderingTerm.asc(e.startsAt)]))
            .get();
    final reminders =
        await (_db.select(_db.companyReminders)
              ..where((r) => r.companyId.equals(id))
              ..orderBy([(r) => OrderingTerm.desc(r.minutesBefore)]))
            .get();
    final logs =
        await (_db.select(_db.logs)
              ..where((l) => l.companyId.equals(id))
              ..orderBy([
                (l) => OrderingTerm.desc(l.createdAt),
                (l) => OrderingTerm.desc(l.id),
              ]))
            .get();

    return CompanyDetail(
      company: row.readTable(_db.companies),
      status: row.readTable(_db.statuses),
      industries: [
        for (final r in industries) r.readTable(_db.industries).name,
      ],
      events: events,
      reminderMinutes: [for (final r in reminders) r.minutesBefore],
      logs: logs,
    );
  }

  Future<void> changeStatus(int companyId, int statusId) {
    return _db.transaction(() async {
      final before = await (_db.select(
        _db.companies,
      )..where((c) => c.id.equals(companyId))).getSingle();
      if (before.statusId == statusId) return;
      await (_db.update(
        _db.companies,
      )..where((c) => c.id.equals(companyId))).write(
        CompaniesCompanion(
          statusId: Value(statusId),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _logStatusChange(companyId, before.statusId, statusId);
    });
  }

  Future<void> addMemo(int companyId, String body) => _db
      .into(_db.logs)
      .insert(
        LogsCompanion.insert(
          companyId: companyId,
          kind: LogKind.memo,
          body: Value(body.trim()),
        ),
      );

  Future<void> updateMemo(int logId, String body) =>
      (_db.update(_db.logs)..where((l) => l.id.equals(logId))).write(
        LogsCompanion(body: Value(body.trim())),
      );

  Future<void> deleteLog(int logId) =>
      (_db.delete(_db.logs)..where((l) => l.id.equals(logId))).go();

  /// Undo 可能な削除。[restore] で戻せる。
  Future<void> softDelete(int companyId) =>
      (_db.update(_db.companies)..where((c) => c.id.equals(companyId))).write(
        CompaniesCompanion(deletedAt: Value(DateTime.now())),
      );

  Future<void> restore(int companyId) =>
      (_db.update(_db.companies)..where((c) => c.id.equals(companyId))).write(
        const CompaniesCompanion(deletedAt: Value(null)),
      );

  /// ソフトデリート済みの企業を物理削除する(起動時に実行)
  Future<int> purgeDeleted() =>
      (_db.delete(_db.companies)..where((c) => c.deletedAt.isNotNull())).go();

  /// 通知対象の予定。削除済みの企業と、お祈り・辞退の企業は除く。
  Future<List<ReminderSource>> fetchReminderSources(DateTime now) async {
    final rows =
        await (_db.select(_db.events).join([
              innerJoin(
                _db.companies,
                _db.companies.id.equalsExp(_db.events.companyId),
              ),
              innerJoin(
                _db.statuses,
                _db.statuses.id.equalsExp(_db.companies.statusId),
              ),
            ])..where(
              _db.events.startsAt.isBiggerThanValue(now) &
                  _db.companies.deletedAt.isNull() &
                  _db.statuses.category
                      .equalsValue(StatusCategory.closed)
                      .not(),
            ))
            .get();
    final custom = <int, Set<int>>{};
    for (final r in await _db.select(_db.companyReminders).get()) {
      custom.putIfAbsent(r.companyId, () => {}).add(r.minutesBefore);
    }
    return [
      for (final r in rows)
        ReminderSource(
          event: r.readTable(_db.events),
          companyName: r.readTable(_db.companies).name,
          useCustomReminders: r.readTable(_db.companies).useCustomReminders,
          customMinutes: custom[r.readTable(_db.companies).id] ?? const {},
        ),
    ];
  }

  /// 通知の再計算が必要になる変更を流す
  Stream<void> watchReminderInputs() => _db.tableUpdates(
    TableUpdateQuery.onAllTables([
      _db.companies,
      _db.statuses,
      _db.events,
      _db.companyReminders,
    ]),
  );

  /// 削除済みを除く全企業を CSV 用に取得する(登録順、ログは古い順)
  Future<List<CsvCompany>> fetchCsvCompanies() async {
    final companies =
        await (_db.select(_db.companies)
              ..where((c) => c.deletedAt.isNull())
              ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
            .get();
    final result = <CsvCompany>[];
    for (final c in companies) {
      final d = (await fetchDetail(c.id))!;
      result.add(
        CsvCompany(
          name: c.name,
          statusName: d.status.name,
          industries: d.industries,
          mypageId: c.mypageId ?? '',
          mypageUrl: c.mypageUrl ?? '',
          events: [
            for (final e in d.events)
              EventDraft(
                type: e.type,
                title: e.title ?? '',
                startsAt: e.startsAt,
              ),
          ],
          reminderMinutes: c.useCustomReminders
              ? d.reminderMinutes.toSet()
              : null,
          logs: [
            for (final l in d.logs.reversed)
              l.kind == LogKind.memo
                  ? CsvLog.memo(l.body, createdAt: l.createdAt)
                  : CsvLog.statusChange(
                      l.fromStatus,
                      l.toStatus,
                      createdAt: l.createdAt,
                    ),
          ],
          createdAt: c.createdAt,
        ),
      );
    }
    return result;
  }

  /// 登録済み(削除済みを除く)の企業名
  Future<Set<String>> existingCompanyNames() async => {
    for (final c in await (_db.select(
      _db.companies,
    )..where((c) => c.deletedAt.isNull())).get())
      c.name,
  };

  /// CSV の企業を登録する。[skipDuplicates] なら同名の企業は飛ばす。
  /// 未知の選考状態は「選考中」分類で、未知の業界はそのまま追加する。
  Future<({int added, int skipped})> importCsvCompanies(
    List<CsvCompany> items, {
    required bool skipDuplicates,
  }) {
    return _db.transaction(() async {
      final existing = await existingCompanyNames();
      final statusIds = {
        for (final s in await _db.select(_db.statuses).get()) s.name: s.id,
      };
      final defaultStatus = await defaultStatusId();
      var added = 0, skipped = 0;

      for (final c in items) {
        if (skipDuplicates && existing.contains(c.name)) {
          skipped++;
          continue;
        }
        var statusId = defaultStatus;
        if (c.statusName != null) {
          statusId =
              statusIds[c.statusName] ??
              (statusIds[c.statusName!] = await addStatus(
                c.statusName!,
                StatusCategory.inProgress,
              ));
        }
        final industryIds = <int>{
          for (final name in c.industries) await addIndustry(name),
        };
        final now = DateTime.now();
        final id = await _db
            .into(_db.companies)
            .insert(
              CompaniesCompanion.insert(
                name: c.name,
                statusId: statusId,
                mypageId: Value(c.mypageId.isEmpty ? null : c.mypageId),
                mypageUrl: Value(c.mypageUrl.isEmpty ? null : c.mypageUrl),
                useCustomReminders: Value(c.reminderMinutes != null),
                createdAt: Value(c.createdAt ?? now),
                updatedAt: Value(now),
              ),
            );
        await _db.batch((b) {
          _insertChildren(
            b,
            id,
            industryIds: industryIds,
            events: c.events,
            reminderMinutes: c.reminderMinutes ?? const {},
          );
          b.insertAll(_db.logs, [
            for (final l in c.logs)
              LogsCompanion.insert(
                companyId: id,
                kind: l.kind,
                body: Value(l.body),
                fromStatus: Value(l.fromStatus),
                toStatus: Value(l.toStatus),
                createdAt: Value(l.createdAt ?? now),
              ),
          ]);
        });
        existing.add(c.name);
        added++;
      }
      return (added: added, skipped: skipped);
    });
  }

  Future<void> updateStatus(int id, String name, StatusCategory category) =>
      (_db.update(_db.statuses)..where((s) => s.id.equals(id))).write(
        StatusesCompanion(name: Value(name), category: Value(category)),
      );

  /// [orderedIds] の順に並び順を振り直す
  Future<void> reorderStatuses(List<int> orderedIds) => _db.batch((b) {
    for (final (i, id) in orderedIds.indexed) {
      b.update(
        _db.statuses,
        StatusesCompanion(sortOrder: Value(i)),
        where: (s) => s.id.equals(id),
      );
    }
  });

  /// 状態ごとの企業数(削除済みの企業も含む:物理削除前に参照しているため)
  Stream<Map<int, int>> watchStatusUsage() {
    final count = _db.companies.id.count();
    final q = _db.selectOnly(_db.companies)
      ..addColumns([_db.companies.statusId, count])
      ..groupBy([_db.companies.statusId]);
    return q.watch().map(
      (rows) => {
        for (final r in rows) r.read(_db.companies.statusId)!: r.read(count)!,
      },
    );
  }

  /// 状態を削除する。使用中なら [moveTo] へ企業を移し、状態変更ログを残す。
  Future<void> deleteStatus(int id, {int? moveTo}) {
    return _db.transaction(() async {
      final users = await (_db.select(
        _db.companies,
      )..where((c) => c.statusId.equals(id))).get();
      if (users.isNotEmpty) {
        if (moveTo == null) {
          throw StateError('使用中の状態には移動先が必要です');
        }
        for (final c in users) {
          // 削除済み企業は履歴を残さず移すだけ
          if (c.deletedAt == null) {
            await changeStatus(c.id, moveTo);
          } else {
            await (_db.update(_db.companies)..where((x) => x.id.equals(c.id)))
                .write(CompaniesCompanion(statusId: Value(moveTo)));
          }
        }
      }
      await (_db.delete(_db.statuses)..where((s) => s.id.equals(id))).go();
    });
  }

  Future<void> renameIndustry(int id, String name) =>
      (_db.update(_db.industries)..where((i) => i.id.equals(id))).write(
        IndustriesCompanion(name: Value(name)),
      );

  Future<void> reorderIndustries(List<int> orderedIds) => _db.batch((b) {
    for (final (i, id) in orderedIds.indexed) {
      b.update(
        _db.industries,
        IndustriesCompanion(sortOrder: Value(i)),
        where: (x) => x.id.equals(id),
      );
    }
  });

  /// 業界ごとの企業数(削除済みの企業は数えない)
  Stream<Map<int, int>> watchIndustryUsage() {
    final count = _db.companyIndustries.companyId.count();
    final q =
        _db.selectOnly(_db.companyIndustries).join([
            innerJoin(
              _db.companies,
              _db.companies.id.equalsExp(_db.companyIndustries.companyId),
              useColumns: false,
            ),
          ])
          ..addColumns([_db.companyIndustries.industryId, count])
          ..where(_db.companies.deletedAt.isNull())
          ..groupBy([_db.companyIndustries.industryId]);
    return q.watch().map(
      (rows) => {
        for (final r in rows)
          r.read(_db.companyIndustries.industryId)!: r.read(count)!,
      },
    );
  }

  /// 業界を削除する。企業との紐付けも外れる(企業自体は残る)。
  Future<void> deleteIndustry(int id) =>
      (_db.delete(_db.industries)..where((i) => i.id.equals(id))).go();
}
