import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../csv/csv_format.dart';
import '../../providers.dart';

Future<void> exportCsv(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final companies = await ref
      .read(companyRepositoryProvider)
      .fetchCsvCompanies();
  if (companies.isEmpty) {
    messenger.showSnackBar(const SnackBar(content: Text('エクスポートする企業がありません')));
    return;
  }
  final bytes = utf8.encode(encodeCompaniesCsv(companies));
  final fileName =
      'shukatsu_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
  if (!context.mounted) return;
  // iPad では共有シートの表示位置が必要
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'text/csv')],
      fileNameOverrides: [fileName],
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}

Future<void> importCsv(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  void show(String msg) => messenger.showSnackBar(SnackBar(content: Text(msg)));

  final files = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );
  if (files.isEmpty) return;

  final CsvParseResult parsed;
  try {
    final text = utf8.decode(await files.first.readAsBytes());
    parsed = parseCompaniesCsv(text);
  } on FormatException {
    show('文字コードを読み取れません。UTF-8(Excelでは「CSV UTF-8」)で保存してください');
    return;
  } on CsvFormatException catch (e) {
    show(e.message);
    return;
  }
  if (parsed.companies.isEmpty) {
    show('取り込める企業がありませんでした');
    return;
  }

  final repo = ref.read(companyRepositoryProvider);
  final existing = await repo.existingCompanyNames();
  final duplicates = parsed.companies
      .where((c) => existing.contains(c.name))
      .length;
  if (!context.mounted) return;
  final choice = await showImportPreview(context, parsed, duplicates);
  if (choice == null) return;

  final r = await repo.importCsvCompanies(
    parsed.companies,
    skipDuplicates: choice == ImportChoice.skipDuplicates,
  );
  show(
    r.skipped == 0
        ? '${r.added}件を取り込みました'
        : '${r.added}件を取り込みました(同名${r.skipped}件はスキップ)',
  );
}

enum ImportChoice { skipDuplicates, addAll }

/// 取り込み内容の確認。同名の企業があればスキップするか選ばせる。
Future<ImportChoice?> showImportPreview(
  BuildContext context,
  CsvParseResult parsed,
  int duplicates,
) {
  const maxWarnings = 5;
  final w = parsed.warnings;
  return showDialog<ImportChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('CSVを取り込む'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${parsed.companies.length}件の企業が見つかりました。'),
            if (duplicates > 0) ...[
              const SizedBox(height: 8),
              Text('うち$duplicates件は同じ名前の企業がすでに登録されています。'),
            ],
            if (w.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '注意(${w.length}件)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              for (final msg in w.take(maxWarnings))
                Text('・$msg', style: Theme.of(context).textTheme.bodySmall),
              if (w.length > maxWarnings)
                Text(
                  'ほか${w.length - maxWarnings}件',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        if (duplicates > 0) ...[
          TextButton(
            onPressed: () => Navigator.pop(context, ImportChoice.addAll),
            child: const Text('すべて追加'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, ImportChoice.skipDuplicates),
            child: const Text('同名はスキップ'),
          ),
        ] else
          FilledButton(
            onPressed: () => Navigator.pop(context, ImportChoice.addAll),
            child: const Text('取り込む'),
          ),
      ],
    ),
  );
}
