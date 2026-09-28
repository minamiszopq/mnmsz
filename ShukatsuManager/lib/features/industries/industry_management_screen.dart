import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers.dart';

class IndustryManagementScreen extends ConsumerStatefulWidget {
  const IndustryManagementScreen({super.key});

  @override
  ConsumerState<IndustryManagementScreen> createState() =>
      _IndustryManagementScreenState();
}

class _IndustryManagementScreenState
    extends ConsumerState<IndustryManagementScreen> {
  /// 並べ替え直後に DB の反映を待たず表示を更新するための一時的な並び
  List<Industry>? _optimistic;

  @override
  Widget build(BuildContext context) {
    final industries = ref.watch(industriesProvider).value;
    final usage = ref.watch(industryUsageProvider).value ?? const {};
    final items = _optimistic ?? industries;
    return Scaffold(
      appBar: AppBar(title: const Text('業界の管理')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('業界を追加'),
        onPressed: industries == null ? null : () => _add(industries),
      ),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text('業界はまだありません'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    '右端をドラッグして並べ替え。この順番が登録画面の選択肢の並びになります。',
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
                      final industry = items[i];
                      final count = usage[industry.id] ?? 0;
                      return ListTile(
                        key: ValueKey(industry.id),
                        title: Text(industry.name),
                        subtitle: count > 0 ? Text('$count社') : null,
                        onTap: () => _rename(items, industry),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: '「${industry.name}」を削除',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(industry, count),
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

  Future<void> _reorder(List<Industry> items, int from, int to) async {
    final list = [...items];
    // onReorderItem の to は移動元を取り除いた後の位置
    list.insert(to, list.removeAt(from));
    setState(() => _optimistic = list);
    await ref.read(companyRepositoryProvider).reorderIndustries([
      for (final x in list) x.id,
    ]);
    if (mounted) setState(() => _optimistic = null);
  }

  Future<void> _add(List<Industry> all) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(
        title: '業界を追加',
        takenNames: {for (final x in all) x.name},
      ),
    );
    if (name == null) return;
    await ref.read(companyRepositoryProvider).addIndustry(name);
  }

  Future<void> _rename(List<Industry> all, Industry industry) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(
        title: '業界名を変更',
        initial: industry.name,
        takenNames: {
          for (final x in all)
            if (x.id != industry.id) x.name,
        },
      ),
    );
    if (name == null || name == industry.name) return;
    await ref.read(companyRepositoryProvider).renameIndustry(industry.id, name);
  }

  Future<void> _delete(Industry industry, int count) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('「${industry.name}」を削除しますか?'),
        content: Text(
          count > 0 ? '$count社からこの業界が外れます。企業は削除されません。' : '企業には影響しません。',
        ),
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
    );
    if (ok ?? false) {
      await ref.read(companyRepositoryProvider).deleteIndustry(industry.id);
    }
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.takenNames,
    this.initial,
  });

  final String title;
  final Set<String> takenNames;
  final String? initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _name.text.trim();
    final duplicate = widget.takenNames.contains(name);
    final canSave = name.isNotEmpty && !duplicate;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _name,
        autofocus: true,
        maxLength: 50,
        decoration: InputDecoration(
          hintText: '例: ゲーム',
          errorText: duplicate ? '同じ名前の業界があります' : null,
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) {
          if (canSave) Navigator.pop(context, name);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: canSave ? () => Navigator.pop(context, name) : null,
          child: Text(widget.initial == null ? '追加' : '保存'),
        ),
      ],
    );
  }
}
