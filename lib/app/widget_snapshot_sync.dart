import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/widget_sync_service.dart';
import '../features/auth/presentation/controllers/auth_providers.dart';
import '../features/budgets/presentation/controllers/budget_providers.dart';
import '../features/profile/presentation/controllers/preferences_providers.dart';
import '../features/transactions/presentation/controllers/transaction_providers.dart';

final widgetSyncServiceProvider = Provider<WidgetSyncService>((ref) {
  return WidgetSyncService();
});

class WidgetSnapshotSync extends ConsumerStatefulWidget {
  const WidgetSnapshotSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WidgetSnapshotSync> createState() => _WidgetSnapshotSyncState();
}

class _WidgetSnapshotSyncState extends ConsumerState<WidgetSnapshotSync> {
  String? _lastSignature;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) {
      return widget.child;
    }

    final authState = ref.watch(authStateChangesProvider);
    final transactionsState = ref.watch(transactionsProvider);
    final budgetsState = ref.watch(budgetsProvider);
    final preferences = ref.watch(userPreferencesProvider).valueOrNull;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final authUser = authState.valueOrNull;
      final syncService = ref.read(widgetSyncServiceProvider);

      if (authState.asData != null && authUser == null) {
        if (_lastSignature != 'cleared') {
          _lastSignature = 'cleared';
          await syncService.clearSnapshot();
        }
        return;
      }

      final transactions = transactionsState.valueOrNull;
      if (authUser == null || transactions == null) {
        return;
      }

      final budgets = budgetsState.valueOrNull ?? const [];

      final currencyCode = preferences?.currencyCode ?? authUser.currencyCode;

      final signature = jsonEncode(<String, dynamic>{
        'currencyCode': currencyCode,
        'transactions': transactions
            .map(
              (item) => <String, dynamic>{
                'id': item.id,
                'updatedAt': item.updatedAt?.toIso8601String(),
                'title': item.title,
                'categoryName': item.categoryName,
                'paymentMethod': item.paymentMethod,
                'transactionDate': item.transactionDate.toIso8601String(),
                'amount': item.amount,
                'type': item.type.name,
              },
            )
            .toList(),
        'budgets': budgets
            .map(
              (item) => <String, dynamic>{
                'id': item.id,
                'updatedAt': item.updatedAt?.toIso8601String(),
                'progress': item.progress,
                'spentAmount': item.spentAmount,
                'limitAmount': item.limitAmount,
              },
            )
            .toList(),
      });

      if (signature == _lastSignature) {
        return;
      }

      _lastSignature = signature;
      await syncService.syncSnapshot(
        currencyCode: currencyCode,
        transactions: transactions,
        budgets: budgets,
      );
    });

    return widget.child;
  }
}
