import 'package:flutter/material.dart';

import '../data/database.dart';
import '../theme.dart';

/// 画面内のセクション見出し
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key, this.padding});

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 28, bottom: 10, left: 4),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final Status status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = statusColors(context, status.category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.name,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// 「あと3日」のような残り時間の表示。[urgent] なら警告色。
class CountdownPill extends StatelessWidget {
  const CountdownPill({
    super.key,
    required this.at,
    required this.now,
    this.urgent = false,
  });

  final DateTime at;
  final DateTime now;
  final bool urgent;

  static String label(DateTime at, DateTime now) {
    final d = at.difference(now);
    if (d.isNegative) return '終了';
    if (d.inDays >= 1) return 'あと${d.inDays}日';
    if (d.inHours >= 1) return 'あと${d.inHours}時間';
    return 'まもなく';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: urgent ? scheme.errorContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label(at, now),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: urgent ? scheme.onErrorContainer : scheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 背景の上に置く白いカード(区切り線つきの項目リスト用)
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, c) in children.indexed) ...[
            if (i > 0) const Divider(height: 1, indent: 56),
            c,
          ],
        ],
      ),
    );
  }
}

IconData eventTypeIcon(EventType t) => switch (t) {
  EventType.deadline => Icons.assignment_late_outlined,
  EventType.interview => Icons.record_voice_over_outlined,
  EventType.webTest => Icons.computer_outlined,
  EventType.seminar => Icons.groups_outlined,
  EventType.other => Icons.event_outlined,
};
