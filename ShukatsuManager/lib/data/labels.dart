import 'database.dart';

extension EventTypeLabel on EventType {
  String get label => switch (this) {
    EventType.deadline => '締切',
    EventType.interview => '面接',
    EventType.webTest => 'Webテスト',
    EventType.seminar => '説明会',
    EventType.other => '予定',
  };
}

extension StatusCategoryLabel on StatusCategory {
  String get label => switch (this) {
    StatusCategory.entry => 'エントリー',
    StatusCategory.inProgress => '選考中',
    StatusCategory.offer => '内定',
    StatusCategory.closed => '終了(お祈り・辞退)',
  };
}
