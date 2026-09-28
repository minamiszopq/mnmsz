import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/company_draft.dart';
import '../../notifications/reminder_sync.dart';
import '../../settings/settings.dart';
import '../industries/industry_management_screen.dart';
import '../statuses/status_management_screen.dart';
import '../../widgets/common.dart';
import 'csv_actions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          const SectionHeader('通知'),
          GroupCard(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('締切・面接のリマインド'),
                value: s.notificationsEnabled,
                onChanged: (on) async {
                  await notifier.setNotificationsEnabled(on);
                  if (!on) return;
                  final scheduler = ref.read(reminderSchedulerProvider);
                  if (await scheduler.requestPermission() || !context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('通知が許可されていません。端末の設定から許可してください'),
                      action: SnackBarAction(
                        label: '設定を開く',
                        onPressed: scheduler.openSystemSettings,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                enabled: s.notificationsEnabled,
                leading: const Icon(Icons.schedule),
                title: const Text('通知タイミング'),
                subtitle: Text(formatReminders(s.defaultReminderMinutes)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showDialog<Set<int>>(
                    context: context,
                    builder: (_) =>
                        _ReminderDialog(initial: s.defaultReminderMinutes),
                  );
                  if (picked != null) {
                    await notifier.setDefaultReminderMinutes(picked);
                  }
                },
              ),
            ],
          ),
          const SectionHeader('表示'),
          GroupCard(
            children: [
              ListTile(
                leading: const Icon(Icons.priority_high),
                title: const Text('締切の強調'),
                subtitle: Text('${s.highlightDays}日以内の予定'),
                trailing: _Stepper(
                  value: s.highlightDays,
                  min: AppSettings.minHighlightDays,
                  max: AppSettings.maxHighlightDays,
                  onChanged: notifier.setHighlightDays,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('テーマ'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, label: Text('自動')),
                      ButtonSegment(value: ThemeMode.light, label: Text('ライト')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('ダーク')),
                    ],
                    selected: {s.themeMode},
                    onSelectionChanged: (v) => notifier.setThemeMode(v.single),
                  ),
                ),
              ),
            ],
          ),
          const SectionHeader('カスタマイズ'),
          GroupCard(
            children: [
              ListTile(
                leading: const Icon(Icons.label_outline),
                title: const Text('選考状態の管理'),
                subtitle: const Text('追加・名前の変更・並べ替え・削除'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const StatusManagementScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('業界の管理'),
                subtitle: const Text('追加・名前の変更・並べ替え・削除'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const IndustryManagementScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SectionHeader('データ管理'),
          GroupCard(
            children: [
              Builder(
                // 共有シートの表示位置(iPad)に行の位置を使う
                builder: (tileContext) => ListTile(
                  leading: const Icon(Icons.upload_file_outlined),
                  title: const Text('CSVエクスポート'),
                  subtitle: const Text('全企業を1つのCSVに書き出します'),
                  onTap: () => exportCsv(tileContext, ref),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('CSVインポート'),
                subtitle: const Text('Excel・Notion などで作った表も読み込めます'),
                onTap: () => importCsv(context, ref),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
            child: Text(
              'データはこの端末の中だけに保存されます。機種変更の前にはCSVエクスポートでバックアップしてください。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 「1週間前・前日」のように、早いタイミングから順に並べる
String formatReminders(Set<int> minutes) {
  if (minutes.isEmpty) return '通知しない';
  final sorted = minutes.toList()..sort((a, b) => b.compareTo(a));
  return sorted.map((m) => reminderOptions[m] ?? '$m分前').join('・');
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          visualDensity: VisualDensity.compact,
          tooltip: '減らす',
          icon: const Icon(Icons.remove),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton.filledTonal(
          visualDensity: VisualDensity.compact,
          tooltip: '増やす',
          icon: const Icon(Icons.add),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _ReminderDialog extends StatefulWidget {
  const _ReminderDialog({required this.initial});

  final Set<int> initial;

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  late final Set<int> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('通知タイミング'),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final MapEntry(key: m, value: label) in reminderOptions.entries)
            CheckboxListTile(
              title: Text(label),
              value: _selected.contains(m),
              onChanged: (on) =>
                  setState(() => on! ? _selected.add(m) : _selected.remove(m)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('保存'),
        ),
      ],
    );
  }
}
