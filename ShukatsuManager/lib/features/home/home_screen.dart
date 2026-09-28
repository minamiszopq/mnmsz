import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/company_repository.dart';
import '../../data/database.dart';
import '../../data/labels.dart';
import '../../data/sample_data.dart';
import '../../providers.dart';
import '../../settings/settings.dart';
import '../../widgets/common.dart';
import '../company_detail/company_detail_screen.dart';
import '../company_form/company_form_screen.dart';
import '../settings/settings_screen.dart';
import 'home_logic.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  SortOrder _order = SortOrder.deadline;

  @override
  Widget build(BuildContext context) {
    final summaries = ref.watch(companySummariesProvider);
    return DefaultTabController(
      length: HomeTab.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('選考管理'),
          actions: [
            IconButton(
              tooltip: '設定',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              ),
            ),
            PopupMenuButton<Object>(
              icon: const Icon(Icons.sort),
              tooltip: '並び替え',
              onSelected: (v) {
                if (v is SortOrder) setState(() => _order = v);
                if (v == 'sample') {
                  insertSampleData(ref.read(databaseProvider));
                }
              },
              itemBuilder: (_) => [
                for (final o in SortOrder.values)
                  CheckedPopupMenuItem(
                    value: o,
                    checked: o == _order,
                    child: Text(o.label),
                  ),
                if (kDebugMode) ...[
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'sample',
                    child: Text('サンプルデータ投入(開発用)'),
                  ),
                ],
              ],
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final t in HomeTab.values)
                Tab(
                  text: switch (summaries.value) {
                    final list? =>
                      '${t.label} ${filterAndSort(list, t, _order).length}',
                    null => t.label,
                  },
                ),
            ],
          ),
        ),
        body: summaries.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('読み込みに失敗しました\n$e')),
          data: (list) => TabBarView(
            children: [
              for (final t in HomeTab.values)
                _CompanyList(items: filterAndSort(list, t, _order), tab: t),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<int>(
              fullscreenDialog: true,
              builder: (_) => const CompanyFormScreen(),
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text('企業を追加'),
        ),
      ),
    );
  }
}

class _CompanyList extends ConsumerWidget {
  const _CompanyList({required this.items, required this.tab});

  final List<CompanySummary> items;
  final HomeTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              tab == HomeTab.all
                  ? 'まだ企業が登録されていません\n右下の「企業を追加」から登録しましょう'
                  : '該当する企業はありません',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    final highlightDays = ref.watch(
      settingsProvider.select((s) => s.highlightDays),
    );
    final now = DateTime.now();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => CompanyCard(
        summary: items[i],
        urgent: isUrgent(items[i], highlightDays, now),
        now: now,
      ),
    );
  }
}

class CompanyCard extends StatelessWidget {
  const CompanyCard({
    super.key,
    required this.summary,
    required this.urgent,
    required this.now,
  });

  final CompanySummary summary;
  final bool urgent;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final event = summary.nextEvent;
    // お祈り・辞退の企業は控えめに表示する
    final closed = summary.status.category == StatusCategory.closed;
    return Opacity(
      opacity: closed ? 0.6 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  CompanyDetailScreen(companyId: summary.company.id),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 締切が近いカードは左端に警告色の帯
                Container(
                  width: 4,
                  color: urgent ? scheme.error : Colors.transparent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                summary.company.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(status: summary.status),
                          ],
                        ),
                        if (summary.industries.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              summary.industries.join(' · '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (event != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: urgent
                                    ? scheme.error
                                    : scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat(
                                  'M/d(E) HH:mm',
                                  'ja',
                                ).format(event.startsAt),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  event.title ?? event.type.label,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              CountdownPill(
                                at: event.startsAt,
                                now: now,
                                urgent: urgent,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
