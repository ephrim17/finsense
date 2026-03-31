import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/finance_enums.dart';
import '../../../budgets/presentation/controllers/budget_providers.dart';
import '../../../goals/presentation/controllers/goals_providers.dart';
import '../../../transactions/domain/entities/transaction_record.dart';
import '../../../transactions/presentation/controllers/transaction_providers.dart';
import '../../domain/entities/dashboard_summary.dart';

String _enumLabel(Object value) => value.toString().split('.').last;

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

final aiInsightsContextProvider = Provider<String>((ref) {
  final transactions = ref
      .watch(transactionsProvider)
      .maybeWhen(
        data: (value) => value,
        orElse: () => const <TransactionRecord>[],
      );
  final budgets = ref
      .watch(budgetsProvider)
      .maybeWhen(data: (value) => value, orElse: () => const []);
  final goals = ref
      .watch(goalsProvider)
      .maybeWhen(data: (value) => value, orElse: () => const []);
  final summary = ref.watch(dashboardSummaryProvider);
  final insight = ref.watch(quickInsightProvider);

  final sortedTransactions = [...transactions]
    ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  final expenseTransactions = sortedTransactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .toList();
  final largestExpense = expenseTransactions.isEmpty
      ? null
      : expenseTransactions.reduce(
          (current, next) => current.amount >= next.amount ? current : next,
        );
  final averageExpense = expenseTransactions.isEmpty
      ? 0.0
      : expenseTransactions.fold<double>(
              0,
              (sum, transaction) => sum + transaction.amount,
            ) /
            expenseTransactions.length;
  final transactionAnomalies = expenseTransactions
      .where(
        (transaction) =>
            averageExpense > 0 && transaction.amount >= averageExpense * 1.75,
      )
      .take(3)
      .map(
        (transaction) => <String, dynamic>{
          'id': transaction.id,
          'title': transaction.title,
          'categoryName': transaction.categoryName,
          'amount': transaction.amount,
          'paymentMethod': transaction.paymentMethod,
          'transactionDate': transaction.transactionDate.toIso8601String(),
        },
      )
      .toList();

  final overspendingHighlights = budgets
      .where(
        (budget) =>
            budget.progress >= 0.8 || budget.health != BudgetHealth.onTrack,
      )
      .map(
        (budget) => <String, dynamic>{
          'categoryName': budget.categoryName,
          'progress': budget.progress,
          'spentAmount': budget.spentAmount,
          'limitAmount': budget.limitAmount,
          'remainingAmount': budget.remainingAmount,
          'health': _enumLabel(budget.health),
        },
      )
      .toList();

  final monthlyGoalTopUp = goals.isEmpty
      ? null
      : ((summary.income - summary.expenses) > 0
            ? ((summary.income - summary.expenses) * 0.2) / goals.length
            : 0.0);

  return jsonEncode(<String, dynamic>{
    'summary': <String, dynamic>{
      'balance': summary.balance,
      'income': summary.income,
      'expenses': summary.expenses,
      'savings': summary.savings,
      'budgetUsed': summary.budgetUsed,
    },
    'quickInsight': insight,
    'signals': <String, dynamic>{
      'averageExpense': averageExpense,
      'largestExpense': largestExpense == null
          ? null
          : <String, dynamic>{
              'id': largestExpense.id,
              'title': largestExpense.title,
              'categoryName': largestExpense.categoryName,
              'amount': largestExpense.amount,
              'paymentMethod': largestExpense.paymentMethod,
              'transactionDate': largestExpense.transactionDate
                  .toIso8601String(),
            },
      'transactionAnomalies': transactionAnomalies,
      'overspendingHighlights': overspendingHighlights,
      'suggestedGoalTopUp': monthlyGoalTopUp,
    },
    'budgets': budgets
        .take(6)
        .map(
          (budget) => <String, dynamic>{
            'categoryName': budget.categoryName,
            'limitAmount': budget.limitAmount,
            'spentAmount': budget.spentAmount,
            'remainingAmount': budget.remainingAmount,
            'progress': budget.progress,
            'health': _enumLabel(budget.health),
          },
        )
        .toList(),
    'goals': goals
        .take(6)
        .map(
          (goal) => <String, dynamic>{
            'title': goal.title,
            'targetAmount': goal.targetAmount,
            'currentAmount': goal.currentAmount,
            'progress': goal.progress,
            'status': _enumLabel(goal.status),
            'deadline': goal.deadline?.toIso8601String(),
          },
        )
        .toList(),
    'recentTransactions': sortedTransactions
        .take(120)
        .map(
          (transaction) => <String, dynamic>{
            'id': transaction.id,
            'title': transaction.title,
            'categoryName': transaction.categoryName,
            'amount': transaction.amount,
            'type': _enumLabel(transaction.type),
            'paymentMethod': transaction.paymentMethod,
            'transactionDate': transaction.transactionDate.toIso8601String(),
          },
        )
        .toList(),
  });
});
