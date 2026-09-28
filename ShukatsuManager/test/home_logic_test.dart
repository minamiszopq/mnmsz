import 'package:flutter_test/flutter_test.dart';
import 'package:shukatsu_manager/data/company_repository.dart';
import 'package:shukatsu_manager/data/database.dart';
import 'package:shukatsu_manager/features/home/home_logic.dart';

final now = DateTime(2026, 9, 21, 12);

CompanySummary s(int id, String name, StatusCategory cat, {Duration? until}) =>
    CompanySummary(
      company: Company(
        id: id,
        name: name,
        statusId: 1,
        useCustomReminders: false,
        createdAt: DateTime(2026, 1, id),
        updatedAt: DateTime(2026, 1, id),
      ),
      status: Status(id: 1, name: 'x', category: cat, sortOrder: 0),
      industries: const [],
      nextEvent: until == null
          ? null
          : Event(
              id: id,
              companyId: id,
              type: EventType.deadline,
              startsAt: now.add(until),
            ),
    );

void main() {
  final items = [
    s(1, 'C社', StatusCategory.entry),
    s(2, 'A社', StatusCategory.inProgress, until: const Duration(days: 5)),
    s(3, 'B社', StatusCategory.inProgress, until: const Duration(days: 1)),
    s(4, 'D社', StatusCategory.offer),
  ];
  List<int> ids(List<CompanySummary> l) => l.map((e) => e.company.id).toList();

  test('締切順: 近い順、締切なしは末尾(登録順)', () {
    expect(ids(filterAndSort(items, HomeTab.all, SortOrder.deadline)), [
      3,
      2,
      1,
      4,
    ]);
  });
  test('登録順・企業名順', () {
    expect(ids(filterAndSort(items, HomeTab.all, SortOrder.created)), [
      1,
      2,
      3,
      4,
    ]);
    expect(ids(filterAndSort(items, HomeTab.all, SortOrder.name)), [
      2,
      3,
      1,
      4,
    ]);
  });
  test('タブでカテゴリ絞り込み', () {
    expect(ids(filterAndSort(items, HomeTab.inProgress, SortOrder.deadline)), [
      3,
      2,
    ]);
  });
  test('強調表示の日数判定', () {
    expect(isUrgent(items[2], 3, now), isTrue);
    expect(isUrgent(items[1], 3, now), isFalse);
    expect(isUrgent(items[1], 5, now), isTrue);
    expect(isUrgent(items[0], 3, now), isFalse);
  });
}
