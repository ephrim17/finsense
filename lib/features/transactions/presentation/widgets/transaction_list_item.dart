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
    final amountAccent = isIncome ? AppColors.success : AppColors.error;
    final categoryVisual = _categoryVisualFor(
      transaction.categoryName,
      transaction.type,
    );
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: categoryVisual.color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          categoryVisual.icon,
          color: categoryVisual.color,
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
              color: amountAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(transaction.paymentMethod, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TransactionCategoryVisual {
  const _TransactionCategoryVisual({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

_TransactionCategoryVisual _categoryVisualFor(
  String category,
  TransactionType type,
) {
  switch (category) {
    case 'Groceries':
      return const _TransactionCategoryVisual(
        icon: Icons.local_grocery_store_rounded,
        color: Color(0xFF2DBE8D),
      );
    case 'Food & Dining':
      return const _TransactionCategoryVisual(
        icon: Icons.restaurant_rounded,
        color: Color(0xFFFF8A5B),
      );
    case 'Travel':
      return const _TransactionCategoryVisual(
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF4F7CFF),
      );
    case 'Transport':
      return const _TransactionCategoryVisual(
        icon: Icons.directions_car_filled_rounded,
        color: Color(0xFFF2C14E),
      );
    case 'Shopping':
      return const _TransactionCategoryVisual(
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFFEF5DA8),
      );
    case 'Bills & Utilities':
      return const _TransactionCategoryVisual(
        icon: Icons.receipt_long_rounded,
        color: Color(0xFF7E67D3),
      );
    case 'Rent':
    case 'Home':
      return const _TransactionCategoryVisual(
        icon: Icons.home_rounded,
        color: Color(0xFF5CC8FF),
      );
    case 'Health':
      return const _TransactionCategoryVisual(
        icon: Icons.favorite_rounded,
        color: Color(0xFFFF5A76),
      );
    case 'Entertainment':
      return const _TransactionCategoryVisual(
        icon: Icons.movie_rounded,
        color: Color(0xFFAE8EFF),
      );
    case 'Education':
      return const _TransactionCategoryVisual(
        icon: Icons.school_rounded,
        color: Color(0xFF3AA0FF),
      );
    case 'Family':
      return const _TransactionCategoryVisual(
        icon: Icons.people_alt_rounded,
        color: Color(0xFFFB7185),
      );
    case 'Salary':
      return const _TransactionCategoryVisual(
        icon: Icons.work_rounded,
        color: Color(0xFF2DBE8D),
      );
    case 'Freelance':
      return const _TransactionCategoryVisual(
        icon: Icons.laptop_mac_rounded,
        color: Color(0xFF4F7CFF),
      );
    case 'Business':
      return const _TransactionCategoryVisual(
        icon: Icons.business_center_rounded,
        color: Color(0xFF7E67D3),
      );
    case 'Investment':
      return const _TransactionCategoryVisual(
        icon: Icons.show_chart_rounded,
        color: Color(0xFFF2C14E),
      );
    case 'Rental Income':
      return const _TransactionCategoryVisual(
        icon: Icons.apartment_rounded,
        color: Color(0xFF5CC8FF),
      );
    case 'Bonus':
      return const _TransactionCategoryVisual(
        icon: Icons.celebration_rounded,
        color: Color(0xFFEF5DA8),
      );
    case 'Gift':
      return const _TransactionCategoryVisual(
        icon: Icons.card_giftcard_rounded,
        color: Color(0xFFFB7185),
      );
    case 'Refund':
      return const _TransactionCategoryVisual(
        icon: Icons.replay_rounded,
        color: Color(0xFF3AA0FF),
      );
    default:
      return _TransactionCategoryVisual(
        icon: type == TransactionType.income
            ? Icons.south_west_rounded
            : Icons.north_east_rounded,
        color: type == TransactionType.income
            ? AppColors.success
            : AppColors.primary,
      );
  }
}
