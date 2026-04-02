import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/finance_enums.dart';
import '../../../transactions/presentation/controllers/transaction_providers.dart';
import '../../domain/entities/report_snapshot.dart';

enum ReportViewMode { expenses, income }
enum ReportChartMode { bar, pie }

final reportViewModeProvider = StateProvider<ReportViewMode>(
  (ref) => ReportViewMode.expenses,
);

final reportChartModeProvider = StateProvider<ReportChartMode>(
  (ref) => ReportChartMode.pie,
);

final reportSnapshotProvider = Provider<ReportSnapshot>((ref) {
  final transactions = ref
      .watch(transactionsProvider)
      .maybeWhen(data: (value) => value, orElse: () => const []);

  final income = transactions
      .where((item) => item.type == TransactionType.income)
      .fold<double>(0, (sum, item) => sum + item.amount);
  final expenses = transactions
      .where((item) => item.type == TransactionType.expense)
      .fold<double>(0, (sum, item) => sum + item.amount);

  final expenseCategorySpend = <String, double>{};
  for (final item in transactions.where(
    (item) => item.type == TransactionType.expense,
  )) {
    expenseCategorySpend.update(
      item.categoryName,
      (value) => value + item.amount,
      ifAbsent: () => item.amount,
    );
  }

  final incomeCategorySpend = <String, double>{};
  for (final item in transactions.where(
    (item) => item.type == TransactionType.income,
  )) {
    incomeCategorySpend.update(
      item.categoryName,
      (value) => value + item.amount,
      ifAbsent: () => item.amount,
    );
  }

  return ReportSnapshot(
    totalIncome: income,
    totalExpenses: expenses,
    expenseCategorySpend: expenseCategorySpend,
    incomeCategorySpend: incomeCategorySpend,
  );
});
