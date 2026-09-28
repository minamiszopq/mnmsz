import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/company_repository.dart';
import '../providers.dart';
import '../settings/settings.dart';
import 'reminder_planner.dart';
import 'reminder_scheduler.dart';

/// main() で実体に差し替える
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => NoopReminderScheduler(),
);

/// データ・設定の変更やアプリ復帰のたびに通知を予約し直す。
/// App で watch して常駐させる。
final reminderSyncProvider = Provider<ReminderSync>((ref) {
  final sync = ReminderSync(
    repository: ref.watch(companyRepositoryProvider),
    scheduler: ref.watch(reminderSchedulerProvider),
    readSettings: () => ref.read(settingsProvider),
    permissionAsked: () =>
        ref.read(sharedPreferencesProvider).getBool(_askedKey) ?? false,
    markPermissionAsked: () =>
        ref.read(sharedPreferencesProvider).setBool(_askedKey, true),
  )..start();
  ref.listen(settingsProvider, (_, _) => sync.request());
  ref.onDispose(sync.dispose);
  return sync;
});

const _askedKey = 'notificationPermissionAsked';

class ReminderSync {
  ReminderSync({
    required this.repository,
    required this.scheduler,
    required this.readSettings,
    required this.permissionAsked,
    required this.markPermissionAsked,
    this.debounce = const Duration(milliseconds: 500),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CompanyRepository repository;
  final ReminderScheduler scheduler;
  final AppSettings Function() readSettings;
  final bool Function() permissionAsked;
  final Future<void> Function() markPermissionAsked;
  final Duration debounce;
  final DateTime Function() _clock;

  StreamSubscription<void>? _sub;
  AppLifecycleListener? _lifecycle;
  Timer? _timer;
  Future<void>? _running;
  bool _pending = false;

  void start() {
    _sub = repository.watchReminderInputs().listen((_) => request());
    // 時間の経過で予約枠(近い60件)がずれるので、復帰時にも計算し直す
    _lifecycle = AppLifecycleListener(onResume: request);
    request();
  }

  /// 連続した変更をまとめてから同期する
  void request() {
    _timer?.cancel();
    _timer = Timer(debounce, () => unawaited(syncNow()));
  }

  Future<void> syncNow() async {
    // 実行中なら終了後にもう一度だけ走らせる
    if (_running != null) {
      _pending = true;
      return _running;
    }
    _running = _sync();
    try {
      await _running;
    } finally {
      _running = null;
    }
    if (_pending) {
      _pending = false;
      await syncNow();
    }
  }

  Future<void> _sync() async {
    try {
      final settings = readSettings();
      if (!settings.notificationsEnabled) {
        await scheduler.replaceAll(const []);
        return;
      }
      final now = _clock();
      final plan = planReminders(
        sources: await repository.fetchReminderSources(now),
        defaultMinutes: settings.defaultReminderMinutes,
        now: now,
      );
      // 初めて通知が必要になったときに一度だけ許可を求める
      if (plan.isNotEmpty && !permissionAsked()) {
        await markPermissionAsked();
        await scheduler.requestPermission();
      }
      await scheduler.replaceAll(plan);
    } catch (e, st) {
      debugPrint('リマインドの予約に失敗しました: $e\n$st');
    }
  }

  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    _lifecycle?.dispose();
  }
}
