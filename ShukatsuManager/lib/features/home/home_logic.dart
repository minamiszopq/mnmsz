import '../../data/company_repository.dart';
import '../../data/database.dart';

/// ホームのタブ。null カテゴリは「すべて」。
enum HomeTab {
  all('すべて', null),
  entry('エントリー中', StatusCategory.entry),
  inProgress('選考中', StatusCategory.inProgress),
  offer('内定', StatusCategory.offer),
  closed('お祈り・辞退', StatusCategory.closed);

  const HomeTab(this.label, this.category);
  final String label;
  final StatusCategory? category;
}

enum SortOrder {
  deadline('締切が近い順'),
  created('登録順'),
  name('企業名順');

  const SortOrder(this.label);
  final String label;
}

List<CompanySummary> filterAndSort(
  List<CompanySummary> items,
  HomeTab tab,
  SortOrder order,
) {
  final filtered = [
    for (final s in items)
      if (tab.category == null || s.status.category == tab.category) s,
  ];
  int compare(CompanySummary a, CompanySummary b) {
    switch (order) {
      case SortOrder.deadline:
        final da = a.nextEvent?.startsAt;
        final db = b.nextEvent?.startsAt;
        // 締切なしは末尾
        if (da == null && db == null) break;
        if (da == null) return 1;
        if (db == null) return -1;
        final c = da.compareTo(db);
        if (c != 0) return c;
      case SortOrder.created:
        break;
      case SortOrder.name:
        final c = a.company.name.compareTo(b.company.name);
        if (c != 0) return c;
    }
    return a.company.createdAt.compareTo(b.company.createdAt);
  }

  return filtered..sort(compare);
}

/// 締切まで [highlightDays] 日以内なら true
bool isUrgent(CompanySummary s, int highlightDays, DateTime now) {
  final at = s.nextEvent?.startsAt;
  return at != null && at.difference(now) <= Duration(days: highlightDays);
}
