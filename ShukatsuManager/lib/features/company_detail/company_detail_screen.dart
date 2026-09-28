import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/company_repository.dart';
import '../../data/database.dart';
import '../../data/labels.dart';
import '../../providers.dart';
import '../../settings/settings.dart';
import '../../theme.dart';
import '../company_form/company_form_screen.dart';
import '../settings/settings_screen.dart' show formatReminders;
import '../../widgets/common.dart';

class CompanyDetailScreen extends ConsumerWidget {
  const CompanyDetailScreen({super.key, required this.companyId});

  final int companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(companyDetailProvider(companyId));
    final d = detail.value;
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (d != null) ...[
            IconButton(
              tooltip: '編集',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<int>(
                  fullscreenDialog: true,
                  builder: (_) => CompanyFormScreen(companyId: companyId),
                ),
              ),
            ),
            IconButton(
              tooltip: '削除',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref, d.company),
            ),
          ],
        ],
      ),
      body: switch (detail) {
        AsyncData(value: final d?) => _DetailBody(detail: d),
        AsyncData() => const Center(child: Text('この企業は削除されました')),
        AsyncError(:final error) => Center(child: Text('読み込みに失敗しました\n$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: d == null
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.note_add_outlined),
              label: const Text('メモを追加'),
              onPressed: () async {
                final body = await showMemoEditor(context);
                if (body != null) {
                  await ref
                      .read(companyRepositoryProvider)
                      .addMemo(companyId, body);
                }
              },
            ),
    );
  }

  /// 削除して一覧に戻り、アプリ全体の SnackBar で「元に戻す」を出す
  Future<void> _delete(BuildContext context, WidgetRef ref, Company c) async {
    final repo = ref.read(companyRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    await repo.softDelete(c.id);
    if (context.mounted) Navigator.of(context).pop();
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('「${c.name}」を削除しました'),
          duration: const Duration(seconds: 6),
          persist: false,
          action: SnackBarAction(
            label: '元に戻す',
            onPressed: () => repo.restore(c.id),
          ),
        ),
      );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.detail});

  final CompanyDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final c = detail.company;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      children: [
        Text(
          c.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusSelector(companyId: c.id, current: detail.status),
            for (final name in detail.industries) _IndustryTag(name),
          ],
        ),
        if (c.mypageId != null || c.mypageUrl != null) ...[
          const SectionHeader('マイページ'),
          GroupCard(
            children: [
              if (c.mypageId != null)
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(c.mypageId!),
                  subtitle: const Text('マイページID(タップでコピー)'),
                  onTap: () => _copy(context, c.mypageId!, 'IDをコピーしました'),
                ),
              if (c.mypageUrl != null)
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: Text(
                    c.mypageUrl!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text('タップで開く・長押しでコピー'),
                  onTap: () => _open(context, c.mypageUrl!),
                  onLongPress: () =>
                      _copy(context, c.mypageUrl!, 'URLをコピーしました'),
                ),
            ],
          ),
        ],
        const SectionHeader('締切・面接日時'),
        if (detail.events.isEmpty)
          const _Empty('予定はありません(編集から追加できます)')
        else
          GroupCard(
            children: [
              for (final e in detail.events)
                _EventTile(
                  event: e,
                  urgent:
                      !e.startsAt.isBefore(DateTime.now()) &&
                      e.startsAt.difference(DateTime.now()) <=
                          Duration(
                            days: ref.watch(
                              settingsProvider.select((s) => s.highlightDays),
                            ),
                          ),
                ),
            ],
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'リマインド: ${_reminderText(c, detail.reminderMinutes, ref.watch(settingsProvider))}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SectionHeader('メモ・履歴'),
        if (detail.logs.isEmpty)
          const _Empty('まだ記録はありません')
        else
          for (final log in detail.logs) _LogItem(log: log),
      ],
    );
  }

  static String _reminderText(
    Company c,
    List<int> minutes,
    AppSettings settings,
  ) {
    if (!settings.notificationsEnabled) return 'オフ(設定画面で変更できます)';
    if (!c.useCustomReminders) {
      return '共通設定(${formatReminders(settings.defaultReminderMinutes)})';
    }
    return formatReminders(minutes.toSet());
  }

  static Future<void> _copy(
    BuildContext context,
    String text,
    String msg,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  static Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('URLを開けませんでした')));
    }
  }
}

class _StatusSelector extends ConsumerWidget {
  const _StatusSelector({required this.companyId, required this.current});

  final int companyId;
  final Status current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () async {
        final picked = await showModalBottomSheet<int>(
          context: context,
          showDragHandle: true,
          builder: (_) => _StatusSheet(currentId: current.id),
        );
        if (picked != null) {
          await ref
              .read(companyRepositoryProvider)
              .changeStatus(companyId, picked);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(status: current),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more, size: 20),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _StatusSheet extends ConsumerWidget {
  const _StatusSheet({required this.currentId});

  final int currentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuses = ref.watch(statusesProvider).value ?? const <Status>[];
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              '選考状態を変更',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final s in statuses)
            ListTile(
              leading: Icon(
                Icons.circle,
                size: 14,
                color: statusColors(context, s.category).$2,
              ),
              title: Text(s.name),
              trailing: s.id == currentId ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, s.id),
            ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.urgent});

  final Event event;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final past = event.startsAt.isBefore(now);
    final muted = past ? Theme.of(context).disabledColor : null;
    return ListTile(
      leading: Icon(eventTypeIcon(event.type), color: muted),
      title: Text(
        event.title ?? event.type.label,
        style: TextStyle(color: muted),
      ),
      subtitle: Text(
        '${DateFormat('yyyy/M/d(E) HH:mm', 'ja').format(event.startsAt)}'
        '${event.title == null ? '' : ' · ${event.type.label}'}',
        style: TextStyle(color: muted),
      ),
      trailing: CountdownPill(at: event.startsAt, now: now, urgent: urgent),
    );
  }
}

class _LogItem extends ConsumerWidget {
  const _LogItem({required this.log});

  final Log log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final time = DateFormat('yyyy/M/d HH:mm', 'ja').format(log.createdAt);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    if (log.kind == LogKind.statusChange) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.swap_horiz, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${log.fromStatus ?? '?'} → ${log.toStatus ?? '?'}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Text(time, style: muted),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(time, style: muted)),
                PopupMenuButton<String>(
                  tooltip: 'メニュー',
                  icon: const Icon(Icons.more_horiz, size: 20),
                  onSelected: (v) async {
                    final repo = ref.read(companyRepositoryProvider);
                    if (v == 'edit') {
                      final body = await showMemoEditor(
                        context,
                        initial: log.body,
                      );
                      if (body != null) await repo.updateMemo(log.id, body);
                    } else if (v == 'delete' && await _confirmDelete(context)) {
                      await repo.deleteLog(log.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('編集')),
                    PopupMenuItem(value: 'delete', child: Text('削除')),
                  ],
                ),
              ],
            ),
            SelectableText(log.body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  static Future<bool> _confirmDelete(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('メモを削除しますか?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('削除'),
            ),
          ],
        ),
      ) ??
      false;
}

/// メモ入力シート。空なら null を返す。
Future<String?> showMemoEditor(BuildContext context, {String? initial}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _MemoEditor(initial: initial),
  );
}

class _MemoEditor extends StatefulWidget {
  const _MemoEditor({this.initial});

  final String? initial;

  @override
  State<_MemoEditor> createState() => _MemoEditorState();
}

class _MemoEditorState extends State<_MemoEditor> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.initial == null ? 'メモを追加' : 'メモを編集',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _text,
            autofocus: true,
            minLines: 4,
            maxLines: 12,
            decoration: const InputDecoration(
              hintText: 'ES本文、面接の振り返りなど',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _text.text.trim().isEmpty
                ? null
                : () => Navigator.pop(context, _text.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class _IndustryTag extends StatelessWidget {
  const _IndustryTag(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        name,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
