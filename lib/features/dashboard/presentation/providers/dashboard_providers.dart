import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/finance_enums.dart';
import '../../../budgets/presentation/controllers/budget_providers.dart';
import '../../../goals/presentation/controllers/goals_providers.dart';
import '../../../transactions/domain/entities/transaction_record.dart';
import '../../../transactions/presentation/controllers/transaction_providers.dart';
import '../../domain/entities/dashboard_summary.dart';

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final transactions = ref
      .watch(transactionsProvider)
      .maybeWhen(
        data: (value) => value,
        orElse: () => const <TransactionRecord>[],
      );
  final budgets = ref
      .watch(budgetsProvider)
      .maybeWhen(data: (value) => value, orElse: () => const []);

  final income = transactions
      .where((item) => item.type == TransactionType.income)
      .fold<double>(0, (sum, item) => sum + item.amount);
  final expenses = transactions
      .where((item) => item.type == TransactionType.expense)
      .fold<double>(0, (sum, item) => sum + item.amount);
  final totalBudget = budgets.fold<double>(
    0,
    (sum, item) => sum + item.limitAmount,
  );
  final spentBudget = budgets.fold<double>(
    0,
    (sum, item) => sum + item.spentAmount,
  );

  return DashboardSummary(
    balance: income - expenses,
    income: income,
    expenses: expenses,
    savings: income - expenses,
    budgetUsed: totalBudget == 0 ? 0 : spentBudget / totalBudget,
  );
});

final quickInsightProvider = Provider<String>((ref) {
  final goals = ref
      .watch(goalsProvider)
      .maybeWhen(data: (value) => value, orElse: () => const []);
  final summary = ref.watch(dashboardSummaryProvider);

  if (summary.expenses > summary.income) {
    return 'Expenses are ahead of income this cycle. Review your top categories early.';
  }
  if (summary.budgetUsed >= 0.8) {
    return 'Your fixed budgets are nearing their limit. A quick trim now keeps the month on track.';
  }
  if (goals.isNotEmpty) {
    return 'Your savings goals are gaining momentum. A small top-up today can accelerate them.';
  }
  return 'You are in a healthy range this month. Keep your habits steady and consistent.';
});
