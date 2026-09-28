import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/company_repository.dart';
import 'data/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final companyRepositoryProvider = Provider((ref) {
  final repo = CompanyRepository(ref.watch(databaseProvider));
  // 前回起動時に削除(Undo 期限切れ)した企業を片付ける
  repo.purgeDeleted();
  return repo;
});

final companySummariesProvider = StreamProvider(
  (ref) => ref.watch(companyRepositoryProvider).watchSummaries(),
);

final statusesProvider = StreamProvider(
  (ref) => ref.watch(companyRepositoryProvider).watchStatuses(),
);

final industriesProvider = StreamProvider(
  (ref) => ref.watch(companyRepositoryProvider).watchIndustries(),
);

final companyDetailProvider = StreamProvider.family<CompanyDetail?, int>(
  (ref, id) => ref.watch(companyRepositoryProvider).watchDetail(id),
);

final statusUsageProvider = StreamProvider(
  (ref) => ref.watch(companyRepositoryProvider).watchStatusUsage(),
);

final industryUsageProvider = StreamProvider(
  (ref) => ref.watch(companyRepositoryProvider).watchIndustryUsage(),
);
