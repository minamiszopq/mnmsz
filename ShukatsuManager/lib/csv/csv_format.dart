import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../data/company_draft.dart';
import '../data/database.dart';
import '../data/labels.dart';

/// CSV の1行 = 1企業。エクスポートとインポートで共通に使う。
class CsvCompany {
  CsvCompany({
    required this.name,
    this.statusName,
    this.industries = const [],
    this.mypageId = '',
    this.mypageUrl = '',
    this.events = const [],
    this.reminderMinutes,
    this.logs = const [],
    this.createdAt,
  });

  final String name;
  final String? statusName;
  final List<String> industries;
  final String mypageId;
  final String mypageUrl;
  final List<EventDraft> events;

  /// null なら共通設定、空集合なら「通知しない」
  final Set<int>? reminderMinutes;
  final List<CsvLog> logs;
  final DateTime? createdAt;
}

class CsvLog {
  const CsvLog.memo(this.body, {this.createdAt})
    : kind = LogKind.memo,
      fromStatus = null,
      toStatus = null;

  const CsvLog.statusChange(this.fromStatus, this.toStatus, {this.createdAt})
    : kind = LogKind.statusChange,
      body = '';

  final LogKind kind;
  final String body;
  final String? fromStatus;
  final String? toStatus;
  final DateTime? createdAt;
}

class CsvParseResult {
  const CsvParseResult(this.companies, this.warnings);

  final List<CsvCompany> companies;

  /// 読み飛ばした行・解釈できなかった値の説明
  final List<String> warnings;
}

class CsvFormatException implements Exception {
  const CsvFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

// 列名。インポート時は別名も受け付ける(Notion・Excel で作った表を想定)。
const _colName = '企業名';
const _colStatus = '選考状態';
const _colIndustries = '業界';
const _colMypageId = 'マイページID';
const _colMypageUrl = 'マイページURL';
const _colEvents = '予定';
const _colReminders = '通知設定';
const _colLogs = 'メモ';
const _colCreatedAt = '登録日';

const _headers = [
  _colName,
  _colStatus,
  _colIndustries,
  _colMypageId,
  _colMypageUrl,
  _colEvents,
  _colReminders,
  _colLogs,
  _colCreatedAt,
];

const _aliases = {
  _colName: ['企業名', '会社名', '企業', 'name', 'company'],
  _colStatus: ['選考状態', 'ステータス', '状態', '選考ステータス', 'status'],
  _colIndustries: ['業界', '業種', '業界名', 'industry'],
  _colMypageId: ['マイページid', 'id', 'ログインid'],
  _colMypageUrl: ['マイページurl', 'url', 'マイページ'],
  _colEvents: ['予定', '締切', '締切・面接日時', '日程'],
  _colReminders: ['通知設定', 'リマインド'],
  _colLogs: ['メモ', '備考', 'memo', 'note'],
  _colCreatedAt: ['登録日', '作成日', 'created'],
};

const _reminderCommon = '共通';
const _reminderNone = 'なし';
const _statusChangeMark = '【状態変更】';

final _dateTimeFmt = DateFormat('yyyy/MM/dd HH:mm');

/// UTF-8 BOM 付き(Excel で文字化けしないように)
String encodeCompaniesCsv(List<CsvCompany> companies) {
  String reminders(Set<int>? m) {
    if (m == null) return _reminderCommon;
    if (m.isEmpty) return _reminderNone;
    final sorted = m.toList()..sort((a, b) => b.compareTo(a));
    return sorted.map((x) => reminderOptions[x] ?? '$x分前').join('・');
  }

  String log(CsvLog l) {
    final at = l.createdAt == null
        ? ''
        : '[${_dateTimeFmt.format(l.createdAt!)}] ';
    return l.kind == LogKind.statusChange
        ? '$at$_statusChangeMark${l.fromStatus ?? ''} → ${l.toStatus ?? ''}'
        : '$at${l.body}';
  }

  final rows = <List<String>>[
    _headers,
    for (final c in companies)
      [
        c.name,
        c.statusName ?? '',
        c.industries.join('\n'),
        c.mypageId,
        c.mypageUrl,
        c.events
            .map(
              (e) => [
                _dateTimeFmt.format(e.startsAt),
                e.type.label,
                if (e.title.isNotEmpty) e.title,
              ].join(' '),
            )
            .join('\n'),
        reminders(c.reminderMinutes),
        // 古い順に並べると、読み返したときに時系列ログとして自然
        c.logs.map(log).join('\n'),
        c.createdAt == null ? '' : _dateTimeFmt.format(c.createdAt!),
      ],
  ];
  return Csv(addBom: true).encode(rows);
}

CsvParseResult parseCompaniesCsv(String text) {
  final input = text.startsWith('﻿') ? text.substring(1) : text;
  // 行番号を Excel の行と一致させるため空行も残す(空行は下で読み飛ばす)。
  // 区切り文字の自動判定は誤判定しうるのでカンマに固定する。
  final rows = Csv(skipEmptyLines: false, autoDetect: false).decode(input);
  if (rows.isEmpty) throw const CsvFormatException('CSVが空です');

  String norm(Object? v) => (v ?? '').toString().trim();
  final header = [
    for (final h in rows.first) norm(h).toLowerCase().replaceAll(' ', ''),
  ];
  final index = <String, int>{};
  for (final MapEntry(key: col, value: names) in _aliases.entries) {
    final i = header.indexWhere(names.contains);
    if (i >= 0) index[col] = i;
  }
  if (!index.containsKey(_colName)) {
    throw const CsvFormatException('1行目に「企業名」の列が見つかりません');
  }

  final companies = <CsvCompany>[];
  final warnings = <String>[];
  for (final (i, row) in rows.skip(1).indexed) {
    final line = i + 2;
    String cell(String col) {
      final c = index[col];
      return c == null || c >= row.length ? '' : norm(row[c]);
    }

    if (row.every((v) => norm(v).isEmpty)) continue;
    final name = cell(_colName);
    if (name.isEmpty) {
      warnings.add('$line行目: 企業名が空のため読み飛ばしました');
      continue;
    }

    final events = <EventDraft>[];
    for (final l in _lines(cell(_colEvents))) {
      final e = _parseEvent(l);
      if (e == null) {
        warnings.add('$line行目: 予定「$l」の日時を読み取れませんでした');
      } else {
        events.add(e);
      }
    }

    Set<int>? reminders;
    final r = cell(_colReminders);
    if (r.isNotEmpty && r != _reminderCommon) {
      reminders = {};
      if (r != _reminderNone) {
        for (final label in r.split(RegExp('[・、,/]'))) {
          final m = reminderOptions.entries
              .where((e) => e.value == label.trim())
              .map((e) => e.key)
              .firstOrNull;
          if (m == null) {
            warnings.add('$line行目: 通知設定「$label」は使えないため無視しました');
          } else {
            reminders.add(m);
          }
        }
      }
    }

    companies.add(
      CsvCompany(
        name: name,
        statusName: cell(_colStatus).isEmpty ? null : cell(_colStatus),
        industries: _lines(cell(_colIndustries)).toList(),
        mypageId: cell(_colMypageId),
        mypageUrl: normalizeUrl(cell(_colMypageUrl)) ?? '',
        events: events,
        reminderMinutes: reminders,
        logs: _parseLogs(cell(_colLogs)),
        createdAt: _parseDateTime(cell(_colCreatedAt)),
      ),
    );
    if (normalizeUrl(cell(_colMypageUrl)) == null) {
      warnings.add('$line行目: URLの形式が正しくないため空にしました');
    }
  }
  return CsvParseResult(companies, warnings);
}

Iterable<String> _lines(String s) =>
    s.split(RegExp(r'\r?\n')).map((l) => l.trim()).where((l) => l.isNotEmpty);

final _datePattern = RegExp(
  r'^(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})(?:\s+(\d{1,2}):(\d{2}))?',
);

DateTime? _parseDateTime(String s) {
  final m = _datePattern.firstMatch(s.trim());
  if (m == null) return null;
  int g(int i) => int.parse(m.group(i) ?? '0');
  return DateTime(g(1), g(2), g(3), g(4), g(5));
}

/// 「2026/10/01 12:00 締切 ES提出」形式。種類が不明なら全体を内容として扱う。
EventDraft? _parseEvent(String line) {
  final m = _datePattern.firstMatch(line);
  if (m == null) return null;
  final at = _parseDateTime(line)!;
  // 時刻がない場合は正午にする(0時だと前日扱いの通知になるため)
  final startsAt = m.group(4) == null
      ? DateTime(at.year, at.month, at.day, 12)
      : at;
  final rest = line.substring(m.end).trim();
  final parts = rest.split(RegExp(r'\s+'));
  final type = EventType.values
      .where((t) => t.label == parts.first)
      .firstOrNull;
  return EventDraft(
    type: type ?? EventType.other,
    title: type == null ? rest : parts.skip(1).join(' '),
    startsAt: startsAt,
  );
}

final _logHead = RegExp(r'^\[(\d{4}/\d{1,2}/\d{1,2} \d{1,2}:\d{2})\]\s?');

/// 「[日時] 本文」で始まる行ごとにログを区切る。日時がない場合はセル全体を1件のメモにする。
List<CsvLog> _parseLogs(String cell) {
  if (cell.trim().isEmpty) return const [];
  final entries = <(DateTime?, List<String>)>[];
  for (final line in cell.split(RegExp(r'\r?\n'))) {
    final m = _logHead.firstMatch(line);
    if (m != null || entries.isEmpty) {
      entries.add((
        m == null ? null : _parseDateTime(m.group(1)!),
        [m == null ? line : line.substring(m.end)],
      ));
    } else {
      entries.last.$2.add(line);
    }
  }
  return [
    for (final (at, lines) in entries)
      if (lines.first.startsWith(_statusChangeMark) && lines.length == 1)
        _statusLog(lines.first.substring(_statusChangeMark.length), at)
      else if (lines.join('\n').trim().isNotEmpty)
        CsvLog.memo(lines.join('\n').trim(), createdAt: at),
  ];
}

CsvLog _statusLog(String s, DateTime? at) {
  final parts = s.split('→').map((p) => p.trim()).toList();
  return CsvLog.statusChange(
    parts.first.isEmpty ? null : parts.first,
    parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null,
    createdAt: at,
  );
}
