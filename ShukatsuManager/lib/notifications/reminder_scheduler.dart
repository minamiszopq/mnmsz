import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_planner.dart';

/// 通知の予約先。テストでは差し替える。
abstract interface class ReminderScheduler {
  /// 予約済みの通知をすべて取り消し、[reminders] で置き換える
  Future<void> replaceAll(List<PlannedReminder> reminders);

  /// 通知の許可を求める。許可済みなら何も表示せず true を返す。
  Future<bool> requestPermission();

  /// 端末の通知設定画面を開く
  Future<void> openSystemSettings();
}

class LocalNotificationScheduler implements ReminderScheduler {
  LocalNotificationScheduler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      '締切・面接のリマインド',
      channelDescription: '登録した締切や面接の前に通知します',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// タイムゾーンとプラグインを初期化する。通知タップ時は [onTap] に企業IDを渡す。
  static Future<LocalNotificationScheduler> init({
    required void Function(int companyId) onTap,
  }) async {
    tzdata.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (e) {
      debugPrint('タイムゾーン取得に失敗したため Asia/Tokyo を使用: $e');
      tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));
    }

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // 許可は起動直後ではなく、必要になったときに求める
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        final id = int.tryParse(r.payload ?? '');
        if (id != null) onTap(id);
      },
    );

    final launch = await plugin.getNotificationAppLaunchDetails();
    final launchId = int.tryParse(launch?.notificationResponse?.payload ?? '');
    if ((launch?.didNotificationLaunchApp ?? false) && launchId != null) {
      onTap(launchId);
    }
    return LocalNotificationScheduler(plugin);
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    await _plugin.cancelAllPendingNotifications();
    for (final r in reminders) {
      await _plugin.zonedSchedule(
        id: r.id,
        scheduledDate: tz.TZDateTime.from(r.fireAt, tz.local),
        notificationDetails: _details,
        // 正確なアラームは権限とストア審査が必要なため、数分の遅れを許容する
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: r.title,
        body: r.body,
        payload: '${r.companyId}',
      );
    }
  }

  @override
  Future<bool> requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            sound: true,
            badge: true,
          ) ??
          false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> openSystemSettings() => _plugin.openAppNotificationSettings();
}

/// 何もしない実装(テスト・未初期化時用)
class NoopReminderScheduler implements ReminderScheduler {
  final List<List<PlannedReminder>> calls = [];

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async =>
      calls.add(reminders);

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> openSystemSettings() async {}
}
