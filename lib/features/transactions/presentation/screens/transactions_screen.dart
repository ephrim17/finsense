import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/finance_defaults.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/empty_state_card.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../profile/presentation/controllers/preferences_providers.dart';
import '../../domain/entities/transaction_record.dart';
import '../controllers/transaction_providers.dart';
import '../widgets/transaction_list_item.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final allTransactions =
        ref.watch(transactionsProvider).valueOrNull ?? const [];
    final user = ref.watch(currentUserProvider).valueOrNull;
    final currencyCode =
        ref.watch(userPreferencesProvider).valueOrNull?.currencyCode ??
        user?.currencyCode ??
        FinanceDefaults.defaultCurrencyCode;
    final transactions = allTransactions.where((item) {
      final normalized = _query.toLowerCase();
      return item.title.toLowerCase().contains(normalized) ||
          item.categoryName.toLowerCase().contains(normalized);
    }).toList();

    return AppScaffold(
      title: 'Transactions',
      body: ListView(
        children: [
          const SectionHeader(
            title: 'Search and filter',
            subtitle: 'Find transactions by title or category',
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search transactions',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 20),
          if (transactions.isEmpty)
            const EmptyStateCard(
              title: 'Nothing matched',
              message: 'Try a different search or add a new transaction.',
              icon: Icons.search_off_rounded,
            )
          else
            PremiumCard(
              child: Column(
                children: transactions
                    .map(
                      (item) => TransactionListItem(
                        transaction: item,
                        currencyCode: currencyCode,
                        onTap: () => _showTransactionDetails(
                          context,
                          item,
                          currencyCode,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    TransactionRecord transaction,
    String currencyCode,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                AppFormatters.currency(
                  transaction.amount,
                  currencyCode: currencyCode,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${transaction.categoryName} • ${transaction.paymentMethod}',
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${AppFormatters.longDate(transaction.transactionDate)}',
              ),
              if (transaction.note != null) ...[
                const SizedBox(height: 8),
                Text(transaction.note!),
              ],
            ],
          ),
        );
      },
    );
  }
}
