import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/company_detail/company_detail_screen.dart';
import 'features/home/home_screen.dart';
import 'notifications/reminder_scheduler.dart';
import 'notifications/reminder_sync.dart';
import 'settings/settings.dart';
import 'theme.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

/// 通知タップで該当企業の詳細を開く(起動直後はフレーム描画後に遷移)
void _openCompany(int companyId) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => CompanyDetailScreen(companyId: companyId),
      ),
    );
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja');
  final prefs = await SharedPreferences.getInstance();
  final scheduler = await LocalNotificationScheduler.init(onTap: _openCompany);
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        reminderSchedulerProvider.overrideWithValue(scheduler),
      ],
      child: const App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 通知の自動再予約を常駐させる
    ref.watch(reminderSyncProvider);
    return MaterialApp(
      navigatorKey: _navigatorKey,
      themeMode: ref.watch(settingsProvider.select((s) => s.themeMode)),
      title: '就活選考管理',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      locale: const Locale('ja'),
      supportedLocales: const [Locale('ja')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeScreen(),
    );
  }
}
