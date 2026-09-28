import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/labels.dart';
import '../../providers.dart';
import '../../theme.dart';
import 'status_dialog.dart';

class StatusManagementScreen extends ConsumerStatefulWidget {
  const StatusManagementScreen({super.key});

  @override
  ConsumerState<StatusManagementScreen> createState() =>
      _StatusManagementScreenState();
}

class _StatusManagementScreenState
    extends ConsumerState<StatusManagementScreen> {
  /// 並べ替え直後に DB の反映を待たず表示を更新するための一時的な並び
  List<Status>? _optimistic;

  @override
  Widget build(BuildContext context) {
    final statuses = ref.watch(statusesProvider).value;
    final usage = ref.watch(statusUsageProvider).value ?? const {};
    final items = _optimistic ?? statuses;
    return Scaffold(
      appBar: AppBar(title: const Text('選考状態の管理')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('状態を追加'),
        onPressed: statuses == null ? null : () => _add(statuses),
      ),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    '右端をドラッグして並べ替え。この順番が選択肢の並びになります。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: items.length,
                    onReorderItem: (from, to) => _reorder(items, from, to),
                    itemBuilder: (context, i) {
                      final s = items[i];
                      final count = usage[s.id] ?? 0;
                      return ListTile(
                        key: ValueKey(s.id),
                        leading: Icon(
                          Icons.circle,
                          size: 14,
                          color: statusColors(context, s.category).$2,
                        ),
                        title: Text(s.name),
                        subtitle: Text(
                          '${s.category.label}${count > 0 ? '・$count社' : ''}',
                        ),
                        onTap: () => _edit(items, s),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: '「${s.name}」を削除',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: items.length <= 1
                                  ? null
                                  : () => _delete(items, s, count),
                            ),
                            ReorderableDragStartListener(
                              index: i,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.drag_handle),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _reorder(List<Status> items, int from, int to) async {
    final list = [...items];
    // onReorderItem の to は移動元を取り除いた後の位置
    list.insert(to, list.removeAt(from));
    setState(() => _optimistic = list);
    await ref.read(companyRepositoryProvider).reorderStatuses([
      for (final s in list) s.id,
    ]);
    if (mounted) setState(() => _optimistic = null);
  }

  Future<void> _add(List<Status> statuses) async {
    final r = await showStatusDialog(context, existing: statuses);
    if (r == null) return;
    await ref.read(companyRepositoryProvider).addStatus(r.$1, r.$2);
  }

  Future<void> _edit(List<Status> statuses, Status s) async {
    final r = await showStatusDialog(context, initial: s, existing: statuses);
    if (r == null) return;
    await ref.read(companyRepositoryProvider).updateStatus(s.id, r.$1, r.$2);
  }

  Future<void> _delete(List<Status> statuses, Status s, int count) async {
    final others = [
      for (final o in statuses)
        if (o.id != s.id) o,
    ];
    final result = await showDialog<({int? moveTo})>(
      context: context,
      builder: (_) => _DeleteDialog(status: s, count: count, others: others),
    );
    if (result == null) return;
    await ref
        .read(companyRepositoryProvider)
        .deleteStatus(s.id, moveTo: result.moveTo);
  }
}

class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog({
    required this.status,
    required this.count,
    required this.others,
  });

  final Status status;
  final int count;
  final List<Status> others;

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  /// 同じ分類の状態を移動先の初期値にする
  late int _moveTo =
      (widget.others
                  .where((o) => o.category == widget.status.category)
                  .firstOrNull ??
              widget.others.first)
          .id;

  @override
  Widget build(BuildContext context) {
    final inUse = widget.count > 0;
    return AlertDialog(
      title: Text('「${widget.status.name}」を削除しますか?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (inUse) ...[
            Text('この状態の企業が${widget.count}社あります。移動先を選んでください。'),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _moveTo,
              decoration: const InputDecoration(
                labelText: '移動先',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final o in widget.others)
                  DropdownMenuItem(value: o.id, child: Text(o.name)),
              ],
              onChanged: (v) => setState(() => _moveTo = v!),
            ),
            const SizedBox(height: 8),
            Text(
              '移動は各企業の履歴に状態変更として記録されます。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ] else
            const Text('過去の履歴に残っている状態名はそのまま表示されます。'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, (moveTo: inUse ? _moveTo : null)),
          child: const Text('削除'),
        ),
      ],
    );
  }
}
