import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/labels.dart';

/// 選考状態の追加・編集ダイアログ。(名前, 分類) を返す。
Future<(String, StatusCategory)?> showStatusDialog(
  BuildContext context, {
  Status? initial,
  required Iterable<Status> existing,
}) {
  return showDialog<(String, StatusCategory)>(
    context: context,
    builder: (_) => _StatusDialog(
      initial: initial,
      takenNames: {
        for (final s in existing)
          if (s.id != initial?.id) s.name,
      },
    ),
  );
}

class _StatusDialog extends StatefulWidget {
  const _StatusDialog({this.initial, required this.takenNames});

  final Status? initial;
  final Set<String> takenNames;

  @override
  State<_StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<_StatusDialog> {
  late final _name = TextEditingController(text: widget.initial?.name);
  late StatusCategory _category =
      widget.initial?.category ?? StatusCategory.inProgress;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _name.text.trim();
    // CSV インポートは名前で状態を探すので、同名は作らせない
    final duplicate = widget.takenNames.contains(name);
    return AlertDialog(
      title: Text(widget.initial == null ? '選考状態を追加' : '選考状態を編集'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: 50,
              decoration: InputDecoration(
                hintText: '例: 三次面接、GD',
                errorText: duplicate ? '同じ名前の状態があります' : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text('分類', style: Theme.of(context).textTheme.labelLarge),
            Text(
              'ホームのどのタブに表示するかを決めます',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            RadioGroup<StatusCategory>(
              groupValue: _category,
              onChanged: (v) => setState(() => _category = v!),
              child: Column(
                children: [
                  for (final c in StatusCategory.values)
                    RadioListTile(
                      value: c,
                      title: Text(c.label),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: name.isEmpty || duplicate
              ? null
              : () => Navigator.pop(context, (name, _category)),
          child: Text(widget.initial == null ? '追加' : '保存'),
        ),
      ],
    );
  }
}
