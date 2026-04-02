import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../features/budgets/domain/entities/budget_plan.dart';
import '../../features/transactions/domain/entities/transaction_record.dart';
import '../constants/widget_constants.dart';

class WidgetSyncService {
  WidgetSyncService();

  static const MethodChannel _channel = MethodChannel(
    WidgetConstants.channelName,
  );

  static String _enumLabel(Object value) => value.toString().split('.').last;

  Future<void> syncSnapshot({
    required String currencyCode,
    required List<TransactionRecord> transactions,
    required List<BudgetPlan> budgets,
  }) async {
    if (!Platform.isIOS) {
      return;
    }

    final sortedTransactions = [...transactions]
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    final now = DateTime.now();
    final monthExpenses = sortedTransactions
        .where(
          (item) =>
              item.type.name == 'expense' &&
              item.transactionDate.year == now.year &&
              item.transactionDate.month == now.month,
        )
        .fold<double>(0, (sum, item) => sum + item.amount);

    final payload = <String, dynamic>{
      'currencyCode': currencyCode,
      'monthExpenseTotal': monthExpenses,
      'recentTransactions': sortedTransactions.take(20).map((item) {
        return <String, dynamic>{
          'id': item.id,
          'title': item.title,
          'categoryName': item.categoryName,
          'amount': item.amount,
          'type': item.type.name,
          'paymentMethod': item.paymentMethod,
          'accountId': item.accountId,
          'note': item.note,
          'transactionDate': item.transactionDate.toIso8601String(),
        };
      }).toList(),
      'budgetHighlights':
          (budgets
                  .where(
                    (item) =>
                        item.progress >= 0.8 ||
                        _enumLabel(item.health) != 'onTrack',
                  )
                  .toList()
                ..sort((a, b) => b.progress.compareTo(a.progress)))
              .take(3)
              .map((item) {
                return <String, dynamic>{
                  'id': item.id,
                  'categoryName': item.categoryName,
                  'limitAmount': item.limitAmount,
                  'spentAmount': item.spentAmount,
                  'remainingAmount': item.remainingAmount,
                  'progress': item.progress,
                  'health': _enumLabel(item.health),
                };
              })
              .toList(),
      'updatedAt': now.toIso8601String(),
    };

    await _channel.invokeMethod<void>('updateWidgetSnapshot', <String, dynamic>{
      'json': jsonEncode(payload),
    });
  }

  Future<void> clearSnapshot() async {
    if (!Platform.isIOS) {
      return;
    }
    await _channel.invokeMethod<void>('clearWidgetSnapshot');
  }
}
