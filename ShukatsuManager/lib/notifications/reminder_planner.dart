import 'package:intl/intl.dart';

import '../data/company_draft.dart';
import '../data/database.dart';
import '../data/labels.dart';

/// 通知の元になる予定(企業情報つき)
class ReminderSource {
  const ReminderSource({
    required this.event,
    required this.companyName,
    required this.useCustomReminders,
    required this.customMinutes,
  });

  final Event event;
  final String companyName;
  final bool useCustomReminders;
  final Set<int> customMinutes;
}

/// 予約する通知1件
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.fireAt,
    required this.title,
    required this.body,
    required this.companyId,
  });

  final int id;
  final DateTime fireAt;
  final String title;
  final String body;
  final int companyId;

  @override
  String toString() => 'PlannedReminder($fireAt, $title, $body)';
}

/// iOS は予約できる通知が 64 件までなので、余裕を持たせて近い順に絞る
const maxScheduledReminders = 60;

/// 企業ごとの設定があればそれを、なければ共通設定を使って通知を組み立てる。
/// 過去の時刻になるものは除き、発火が近い順に [limit] 件まで返す。
List<PlannedReminder> planReminders({
  required List<ReminderSource> sources,
  required Set<int> defaultMinutes,
  required DateTime now,
  int limit = maxScheduledReminders,
}) {
  final fmt = DateFormat('M/d(E) HH:mm', 'ja');
  final all = <PlannedReminder>[];
  for (final s in sources) {
    final minutes = s.useCustomReminders ? s.customMinutes : defaultMinutes;
    final e = s.event;
    final what = e.title ?? e.type.label;
    for (final m in minutes) {
      final fireAt = e.startsAt.subtract(Duration(minutes: m));
      if (!fireAt.isAfter(now)) continue;
      all.add(
        PlannedReminder(
          id: 0,
          fireAt: fireAt,
          title: '${s.companyName}:$what(${reminderOptions[m] ?? '$m分前'})',
          body: '${fmt.format(e.startsAt)} $what',
          companyId: e.companyId,
        ),
      );
    }
  }
  all.sort((a, b) => a.fireAt.compareTo(b.fireAt));
  // 毎回すべて取り消してから予約し直すので、ID は並び順で振れば十分
  return [
    for (final (i, r) in all.take(limit).indexed)
      PlannedReminder(
        id: i,
        fireAt: r.fireAt,
        title: r.title,
        body: r.body,
        companyId: r.companyId,
      ),
  ];
}
