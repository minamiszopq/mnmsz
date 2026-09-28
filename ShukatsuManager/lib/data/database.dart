import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// ホームのタブ分類。自由追加した状態もいずれかに属する。
enum StatusCategory { entry, inProgress, offer, closed }

/// 選考状態マスタ(ユーザーが追加・並べ替え可能)
@DataClassName('Status')
class Statuses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get category => intEnum<StatusCategory>()();
  IntColumn get sortOrder => integer()();
}

/// 業界マスタ(ユーザーが追加可能)
class Industries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50).unique()();

  /// v2 で追加
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class Companies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get statusId => integer().references(Statuses, #id)();
  TextColumn get mypageId => text().nullable()();
  TextColumn get mypageUrl => text().nullable()();

  /// true のとき CompanyReminders を全体設定より優先する
  BoolColumn get useCustomReminders =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// Undo 用のソフトデリート。一定時間後に物理削除する。
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// 企業と業界の多対多
class CompanyIndustries extends Table {
  IntColumn get companyId =>
      integer().references(Companies, #id, onDelete: KeyAction.cascade)();
  IntColumn get industryId =>
      integer().references(Industries, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {companyId, industryId};
}

enum EventType { deadline, interview, webTest, seminar, other }

/// 締切・面接などの予定(企業と1対多)
class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get companyId =>
      integer().references(Companies, #id, onDelete: KeyAction.cascade)();
  IntColumn get type => intEnum<EventType>()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get startsAt => dateTime()();
}

/// 企業ごとのリマインド設定(予定の何分前に通知するか、複数可)
class CompanyReminders extends Table {
  IntColumn get companyId =>
      integer().references(Companies, #id, onDelete: KeyAction.cascade)();
  IntColumn get minutesBefore => integer()();

  @override
  Set<Column> get primaryKey => {companyId, minutesBefore};
}

enum LogKind { memo, statusChange }

/// 時系列ログ(メモ + 状態変更の自動記録)
class Logs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get companyId =>
      integer().references(Companies, #id, onDelete: KeyAction.cascade)();
  IntColumn get kind => intEnum<LogKind>()();
  TextColumn get body => text().withDefault(const Constant(''))();

  /// 状態名はマスタ変更・削除後も読めるよう文字列で保持する
  TextColumn get fromStatus => text().nullable()();
  TextColumn get toStatus => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    Statuses,
    Industries,
    Companies,
    CompanyIndustries,
    Events,
    CompanyReminders,
    Logs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'shukatsu'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // 業界の並べ替えに対応。既存の並びは登録順(id順)を引き継ぐ。
        await m.addColumn(industries, industries.sortOrder);
        await customStatement('UPDATE industries SET sort_order = id');
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seed() async {
    const seedStatuses = [
      ('エントリー', StatusCategory.entry),
      ('書類選考', StatusCategory.inProgress),
      ('一次面接', StatusCategory.inProgress),
      ('二次面接', StatusCategory.inProgress),
      ('最終面接', StatusCategory.inProgress),
      ('内定', StatusCategory.offer),
      ('お祈り', StatusCategory.closed),
      ('辞退', StatusCategory.closed),
    ];
    const seedIndustries = [
      'IT・通信',
      'メーカー',
      '商社',
      '金融',
      'コンサル',
      '広告・マスコミ',
      '小売・流通',
      'サービス',
      'インフラ',
      '官公庁・公社',
    ];
    await batch((b) {
      b.insertAll(statuses, [
        for (final (i, (name, cat)) in seedStatuses.indexed)
          StatusesCompanion.insert(name: name, category: cat, sortOrder: i),
      ]);
      b.insertAll(industries, [
        for (final name in seedIndustries)
          IndustriesCompanion.insert(name: name),
      ]);
    });
  }
}
