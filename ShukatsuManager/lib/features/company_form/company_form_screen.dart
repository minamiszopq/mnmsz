import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/company_draft.dart';
import '../../data/database.dart';
import '../../data/labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../statuses/status_dialog.dart';

/// 企業の新規登録([companyId] が null)/ 編集画面
class CompanyFormScreen extends ConsumerStatefulWidget {
  const CompanyFormScreen({super.key, this.companyId});

  final int? companyId;

  @override
  ConsumerState<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends ConsumerState<CompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mypageId = TextEditingController();
  final _mypageUrl = TextEditingController();
  final _memo = TextEditingController();
  CompanyDraft? _draft;
  bool _dirty = false;
  bool _saving = false;

  bool get _isNew => widget.companyId == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(companyRepositoryProvider);
    final draft = _isNew
        ? CompanyDraft(statusId: await repo.defaultStatusId())
        : await repo.loadDraft(widget.companyId!);
    _name.text = draft.name;
    _mypageId.text = draft.mypageId;
    _mypageUrl.text = draft.mypageUrl;
    if (mounted) setState(() => _draft = draft);
  }

  @override
  void dispose() {
    for (final c in [_name, _mypageId, _mypageUrl, _memo]) {
      c.dispose();
    }
    super.dispose();
  }

  void _update(VoidCallback fn) => setState(() {
    fn();
    _dirty = true;
  });

  Future<void> _save() async {
    final draft = _draft!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    draft
      ..name = _name.text
      ..mypageId = _mypageId.text
      ..mypageUrl = normalizeUrl(_mypageUrl.text)!
      ..memo = _memo.text;
    final id = await ref
        .read(companyRepositoryProvider)
        .saveDraft(draft, id: widget.companyId);
    if (!mounted) return;
    _dirty = false;
    Navigator.of(context).pop(id);
  }

  Future<bool> _confirmDiscard() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('変更を破棄しますか?'),
        content: const Text('入力した内容は保存されません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('編集を続ける'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('破棄'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          _dirty = false;
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? '企業を追加' : '企業を編集'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: draft == null || _saving ? null : _save,
                child: const Text('保存'),
              ),
            ),
          ],
        ),
        body: draft == null
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    const SectionHeader('基本情報'),
                    TextFormField(
                      controller: _name,
                      autofocus: _isNew,
                      decoration: const InputDecoration(
                        labelText: '企業名 *',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _dirty = true,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '企業名を入力してください'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _StatusField(
                      value: draft.statusId,
                      onChanged: (id) => _update(() => draft.statusId = id),
                    ),
                    const SizedBox(height: 16),
                    _IndustryField(
                      selected: draft.industryIds,
                      onToggle: (id) => _update(() {
                        if (!draft.industryIds.remove(id)) {
                          draft.industryIds.add(id);
                        }
                      }),
                    ),
                    const SectionHeader('マイページ'),
                    TextFormField(
                      controller: _mypageId,
                      decoration: const InputDecoration(
                        labelText: 'マイページID',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _dirty = true,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mypageUrl,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'マイページURL',
                        hintText: 'https://',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _dirty = true,
                      validator: (v) => normalizeUrl(v ?? '') == null
                          ? 'URLの形式が正しくありません'
                          : null,
                    ),
                    const SectionHeader('締切・面接日時'),
                    _EventList(
                      events: draft.events,
                      onChanged: () => _update(
                        () => draft.events.sort(
                          (a, b) => a.startsAt.compareTo(b.startsAt),
                        ),
                      ),
                    ),
                    const SectionHeader('リマインド'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('この企業だけ通知タイミングを変える'),
                      subtitle: const Text('オフのときは設定画面の共通設定を使います'),
                      value: draft.useCustomReminders,
                      onChanged: (v) =>
                          _update(() => draft.useCustomReminders = v),
                    ),
                    if (draft.useCustomReminders)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final MapEntry(key: min, value: label)
                              in reminderOptions.entries)
                            FilterChip(
                              label: Text(label),
                              selected: draft.reminderMinutes.contains(min),
                              onSelected: (on) => _update(
                                () => on
                                    ? draft.reminderMinutes.add(min)
                                    : draft.reminderMinutes.remove(min),
                              ),
                            ),
                        ],
                      ),
                    if (_isNew) ...[
                      const SectionHeader('メモ'),
                      TextFormField(
                        controller: _memo,
                        minLines: 3,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          hintText: '志望動機、ES本文など(登録後も詳細画面で追加できます)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _dirty = true,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatusField extends ConsumerWidget {
  const _StatusField({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuses = ref.watch(statusesProvider).value ?? const <Status>[];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: statuses.any((s) => s.id == value) ? value : null,
            key: ValueKey(statuses.length),
            decoration: const InputDecoration(
              labelText: '選考状態',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final s in statuses)
                DropdownMenuItem(value: s.id, child: Text(s.name)),
            ],
            onChanged: (id) => id == null ? null : onChanged(id),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          tooltip: '状態を追加',
          padding: const EdgeInsets.all(14),
          icon: const Icon(Icons.add),
          onPressed: () async {
            final result = await showStatusDialog(context, existing: statuses);
            if (result == null) return;
            final id = await ref
                .read(companyRepositoryProvider)
                .addStatus(result.$1, result.$2);
            onChanged(id);
          },
        ),
      ],
    );
  }
}

class _IndustryField extends ConsumerWidget {
  const _IndustryField({required this.selected, required this.onToggle});

  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final industries = ref.watch(industriesProvider).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('業界(複数選択可)', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final i in industries)
              FilterChip(
                label: Text(i.name),
                selected: selected.contains(i.id),
                onSelected: (_) => onToggle(i.id),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('業界を追加'),
              onPressed: () async {
                final name = await _promptText(context, '業界を追加', '例: ゲーム');
                if (name == null) return;
                final id = await ref
                    .read(companyRepositoryProvider)
                    .addIndustry(name);
                if (!selected.contains(id)) onToggle(id);
              },
            ),
          ],
        ),
      ],
    );
  }
}

Future<String?> _promptText(BuildContext context, String title, String hint) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: (v) =>
            Navigator.pop(context, v.trim().isEmpty ? null : v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            final v = controller.text.trim();
            Navigator.pop(context, v.isEmpty ? null : v);
          },
          child: const Text('追加'),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}

class _EventList extends StatelessWidget {
  const _EventList({required this.events, required this.onChanged});

  final List<EventDraft> events;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy/M/d(E) HH:mm', 'ja');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, e) in events.indexed)
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: ListTile(
              leading: Icon(eventTypeIcon(e.type)),
              title: Text(e.title.isEmpty ? e.type.label : e.title),
              subtitle: Text(fmt.format(e.startsAt)),
              trailing: IconButton(
                tooltip: '削除',
                icon: const Icon(Icons.close),
                onPressed: () {
                  events.removeAt(i);
                  onChanged();
                },
              ),
              onTap: () async {
                final edited = await showEventEditor(context, initial: e);
                if (edited == null) return;
                events[i] = edited;
                onChanged();
              },
            ),
          ),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('予定を追加'),
          onPressed: () async {
            final added = await showEventEditor(context);
            if (added == null) return;
            events.add(added);
            onChanged();
          },
        ),
      ],
    );
  }
}

Future<EventDraft?> showEventEditor(
  BuildContext context, {
  EventDraft? initial,
}) {
  return showModalBottomSheet<EventDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _EventEditor(initial: initial),
  );
}

class _EventEditor extends StatefulWidget {
  const _EventEditor({this.initial});

  final EventDraft? initial;

  @override
  State<_EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends State<_EventEditor> {
  late EventType _type = widget.initial?.type ?? EventType.deadline;
  late final _title = TextEditingController(text: widget.initial?.title);
  late DateTime _at = widget.initial?.startsAt ?? _defaultStart();

  static DateTime _defaultStart() {
    final t = DateTime.now().add(const Duration(days: 1));
    return DateTime(t.year, t.month, t.day, 12);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _at,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (d != null) {
      setState(
        () => _at = DateTime(d.year, d.month, d.day, _at.hour, _at.minute),
      );
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_at),
    );
    if (t != null) {
      setState(
        () => _at = DateTime(_at.year, _at.month, _at.day, t.hour, t.minute),
      );
    }
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
            widget.initial == null ? '予定を追加' : '予定を編集',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              for (final t in EventType.values)
                ChoiceChip(
                  label: Text(t.label),
                  selected: t == _type,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: '内容(任意)',
              hintText: '例: ES提出、一次面接',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(DateFormat('yyyy/M/d(E)', 'ja').format(_at)),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: Text(DateFormat('HH:mm').format(_at)),
                  onPressed: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              EventDraft(type: _type, title: _title.text.trim(), startsAt: _at),
            ),
            child: const Text('決定'),
          ),
        ],
      ),
    );
  }
}
