import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/finance_enums.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../budgets/domain/entities/budget_plan.dart';
import '../../../budgets/presentation/controllers/budget_providers.dart';
import '../../../goals/domain/entities/savings_goal.dart';
import '../../../goals/presentation/controllers/goals_providers.dart';
import '../../../profile/presentation/controllers/preferences_providers.dart';
import '../../../transactions/domain/entities/ai_insight_payload.dart';
import '../../../transactions/domain/entities/transaction_record.dart';
import '../../../transactions/presentation/controllers/financial_insights_providers.dart';
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

final reportAiSummaryProvider =
    FutureProvider.autoDispose.family<AiInsightPayload, ReportViewMode>((
      ref,
      viewMode,
    ) async {
      final service = ref.read(financialInsightsServiceProvider);
      final List<TransactionRecord> transactions = ref
          .read(transactionsProvider)
          .maybeWhen(data: (value) => value, orElse: () => const []);
      final List<BudgetPlan> budgets = ref
          .read(budgetsProvider)
          .maybeWhen(data: (value) => value, orElse: () => const []);
      final List<SavingsGoal> goals = ref
          .read(goalsProvider)
          .maybeWhen(data: (value) => value, orElse: () => const []);
      final user = ref.read(currentUserProvider).valueOrNull;
      final currencyCode =
          ref.read(userPreferencesProvider).valueOrNull?.currencyCode ??
          user?.currencyCode ??
          'INR';

      final modePrompt = viewMode == ReportViewMode.expenses
          ? 'Summarize the current expense report. Focus on spending concentration, standout categories, and one useful action.'
          : 'Summarize the current income report. Focus on income composition, stability, and one useful action.';

      return service.askCoach(
        userPrompt: modePrompt,
        transactions: transactions,
        budgets: budgets,
        goals: goals,
        currencyCode: currencyCode,
      );
    });
