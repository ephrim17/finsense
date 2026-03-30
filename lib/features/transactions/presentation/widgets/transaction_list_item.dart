import 'package:flutter/material.dart';

import '../../../../core/enums/finance_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/transaction_record.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.currencyCode,
    this.onTap,
  });

  final TransactionRecord transaction;
  final String currencyCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final accent = isIncome ? AppColors.success : AppColors.error;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.lightPurple,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: AppColors.primary,
        ),
      ),
      title: Text(transaction.title, style: textTheme.titleMedium),
      subtitle: Text(
        '${transaction.categoryName} • ${AppFormatters.longDate(transaction.transactionDate)}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isIncome ? '+' : '-'}${AppFormatters.currency(transaction.amount, currencyCode: currencyCode)}',
            style: textTheme.titleMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(transaction.paymentMethod, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
