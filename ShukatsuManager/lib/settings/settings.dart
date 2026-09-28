import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// main() で実体に差し替える
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

/// アプリ全体の設定(shared_preferences に保存)
@immutable
class AppSettings {
  const AppSettings({
    this.notificationsEnabled = true,
    this.defaultReminderMinutes = const {1440, 60},
    this.highlightDays = 3,
    this.themeMode = ThemeMode.system,
  });

  final bool notificationsEnabled;

  /// 企業ごとの設定がないときに使う通知タイミング(予定の何分前か)
  final Set<int> defaultReminderMinutes;

  /// 締切まで何日以内なら一覧で強調するか
  final int highlightDays;
  final ThemeMode themeMode;

  static const minHighlightDays = 1;
  static const maxHighlightDays = 14;

  AppSettings copyWith({
    bool? notificationsEnabled,
    Set<int>? defaultReminderMinutes,
    int? highlightDays,
    ThemeMode? themeMode,
  }) => AppSettings(
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    defaultReminderMinutes:
        defaultReminderMinutes ?? this.defaultReminderMinutes,
    highlightDays: highlightDays ?? this.highlightDays,
    themeMode: themeMode ?? this.themeMode,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _notifications = 'notificationsEnabled';
  static const _reminders = 'defaultReminderMinutes';
  static const _highlight = 'highlightDays';
  static const _theme = 'themeMode';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final p = ref.watch(sharedPreferencesProvider);
    const d = AppSettings();
    final themeName = p.getString(_theme);
    return AppSettings(
      notificationsEnabled: p.getBool(_notifications) ?? d.notificationsEnabled,
      defaultReminderMinutes:
          p.getStringList(_reminders)?.map(int.parse).toSet() ??
          d.defaultReminderMinutes,
      highlightDays: (p.getInt(_highlight) ?? d.highlightDays).clamp(
        AppSettings.minHighlightDays,
        AppSettings.maxHighlightDays,
      ),
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == themeName,
        orElse: () => d.themeMode,
      ),
    );
  }

  Future<void> setNotificationsEnabled(bool v) async {
    state = state.copyWith(notificationsEnabled: v);
    await _prefs.setBool(_notifications, v);
  }

  Future<void> setDefaultReminderMinutes(Set<int> v) async {
    state = state.copyWith(defaultReminderMinutes: v);
    await _prefs.setStringList(_reminders, [for (final m in v) '$m']);
  }

  Future<void> setHighlightDays(int v) async {
    state = state.copyWith(highlightDays: v);
    await _prefs.setInt(_highlight, v);
  }

  Future<void> setThemeMode(ThemeMode v) async {
    state = state.copyWith(themeMode: v);
    await _prefs.setString(_theme, v.name);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
