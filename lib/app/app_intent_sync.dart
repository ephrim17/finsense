import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/finance_defaults.dart';
import '../core/enums/finance_enums.dart';
import '../core/services/app_intent_service.dart';
import '../features/auth/presentation/controllers/auth_providers.dart';
import '../features/transactions/presentation/controllers/transaction_providers.dart';

final appIntentServiceProvider = Provider<AppIntentService>((ref) {
  return AppIntentService();
});

class AppIntentSync extends ConsumerStatefulWidget {
  const AppIntentSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppIntentSync> createState() => _AppIntentSyncState();
}

class _AppIntentSyncState extends ConsumerState<AppIntentSync> {
  bool _isConsuming = false;
  String? _lastHandledSignature;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) {
      return widget.child;
    }

    final authState = ref.watch(authStateChangesProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _isConsuming) {
        return;
      }

      final user = authState.valueOrNull;
      if (user == null) {
        return;
      }

      _isConsuming = true;
      try {
        final payload = await ref
            .read(appIntentServiceProvider)
            .consumePendingTransactionIntent();

        if (!mounted || payload == null) {
          return;
        }

        final signature = jsonEncode(payload);
        if (signature == _lastHandledSignature) {
          return;
        }

        final amount = _parseAmount(payload['amount']);
        final title = (payload['title'] as String?)?.trim() ?? '';
        if (title.isEmpty || amount <= 0) {
          return;
        }

        final type = _parseTransactionType(payload['type'] as String?);
        final categoryName =
            ((payload['categoryName'] as String?)?.trim().isNotEmpty ?? false)
            ? (payload['categoryName'] as String).trim()
            : FinanceDefaults.categoriesFor(type).first;
        final paymentMethod =
            ((payload['paymentMethod'] as String?)?.trim().isNotEmpty ?? false)
            ? (payload['paymentMethod'] as String).trim()
            : 'Card';
        final accountId =
            ((payload['accountId'] as String?)?.trim().isNotEmpty ?? false)
            ? (payload['accountId'] as String).trim()
            : 'Main Account';
        final note = (payload['note'] as String?)?.trim();
        final transactionDate =
            DateTime.tryParse(payload['transactionDate'] as String? ?? '') ??
            DateTime.now();

        _lastHandledSignature = signature;
        await ref
            .read(transactionActionControllerProvider.notifier)
            .save(
              userId: user.id,
              title: title,
              amount: amount,
              categoryName: categoryName,
              accountId: accountId,
              paymentMethod: paymentMethod,
              transactionDate: transactionDate,
              type: type,
              note: note == null || note.isEmpty ? null : note,
            );
      } finally {
        _isConsuming = false;
      }
    });

    return widget.child;
  }

  double _parseAmount(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  TransactionType _parseTransactionType(String? value) {
    return value == 'income' ? TransactionType.income : TransactionType.expense;
  }
}
