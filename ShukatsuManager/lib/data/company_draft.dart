import 'database.dart';

/// 登録・編集フォームの入力内容
class CompanyDraft {
  CompanyDraft({
    this.name = '',
    required this.statusId,
    Set<int>? industryIds,
    this.mypageId = '',
    this.mypageUrl = '',
    List<EventDraft>? events,
    this.useCustomReminders = false,
    Set<int>? reminderMinutes,
    this.memo = '',
  }) : industryIds = industryIds ?? {},
       events = events ?? [],
       reminderMinutes = reminderMinutes ?? {};

  String name;
  int statusId;
  Set<int> industryIds;
  String mypageId;
  String mypageUrl;
  List<EventDraft> events;
  bool useCustomReminders;
  Set<int> reminderMinutes;

  /// 新規登録時のみ使用。最初のメモとしてログに追加される。
  String memo;
}

class EventDraft {
  EventDraft({required this.type, this.title = '', required this.startsAt});

  EventType type;
  String title;
  DateTime startsAt;
}

/// リマインドの選択肢(予定の何分前か)
const reminderOptions = <int, String>{
  10080: '1週間前',
  4320: '3日前',
  1440: '前日',
  180: '3時間前',
  60: '1時間前',
};

/// スキームがなければ https:// を補う。不正な URL は null。
String? normalizeUrl(String input) {
  final s = input.trim();
  if (s.isEmpty) return '';
  final withScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(s)
      ? s
      : 'https://$s';
  final uri = Uri.tryParse(withScheme);
  if (uri == null ||
      !(uri.scheme == 'http' || uri.scheme == 'https') ||
      !uri.host.contains('.')) {
    return null;
  }
  return withScheme;
}
