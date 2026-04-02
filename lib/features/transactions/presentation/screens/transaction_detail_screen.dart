import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/finance_defaults.dart';
import '../../../../core/enums/finance_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/empty_state_card.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../profile/presentation/controllers/preferences_providers.dart';
import '../../presentation/controllers/transaction_providers.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions =
        ref.watch(transactionsProvider).valueOrNull ?? const [];
    final transaction = transactions
        .where((item) => item.id == transactionId)
        .firstOrNull;
    final user = ref.watch(currentUserProvider).valueOrNull;
    final currencyCode =
        ref.watch(userPreferencesProvider).valueOrNull?.currencyCode ??
        user?.currencyCode ??
        FinanceDefaults.defaultCurrencyCode;

    if (transaction == null) {
      return const AppScaffold(
        title: 'Transaction',
        body: EmptyStateCard(
          title: 'Transaction not found',
          message:
              'This transaction may have been removed or is not available.',
          icon: Icons.receipt_long_rounded,
        ),
      );
    }

    final isIncome = transaction.type == TransactionType.income;
    final accent = isIncome ? AppColors.success : AppColors.error;

    return AppScaffold(
      title: 'Transaction',
      body: ListView(
        children: [
          PremiumCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${isIncome ? '+' : '-'}${AppFormatters.currency(transaction.amount, currencyCode: currencyCode)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                _DetailRow(label: 'Category', value: transaction.categoryName),
                _DetailRow(
                  label: 'Payment method',
                  value: transaction.paymentMethod,
                ),
                _DetailRow(
                  label: 'Transaction date',
                  value: AppFormatters.longDate(transaction.transactionDate),
                ),
                _DetailRow(
                  label: 'Created',
                  value: AppFormatters.longDate(transaction.createdAt),
                ),
                if (transaction.note != null && transaction.note!.isNotEmpty)
                  _DetailRow(label: 'Note', value: transaction.note!),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(
                          '/transactions/$transactionId/edit',
                          extra: transaction,
                        ),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        onPressed: () => _confirmDelete(context, ref, transaction),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    transaction,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text(
          'This will permanently remove "${transaction.title}" from your transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    await ref
        .read(transactionActionControllerProvider.notifier)
        .delete(userId: transaction.userId, transactionId: transaction.id);

    if (context.mounted) {
      context.pop();
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
