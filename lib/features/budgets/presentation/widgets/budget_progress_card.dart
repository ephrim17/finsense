import 'package:flutter/material.dart';

import '../../../../core/enums/finance_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../domain/entities/budget_plan.dart';

class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    super.key,
    required this.budget,
    required this.currencyCode,
  });

  final BudgetPlan budget;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusColor = switch (budget.health) {
      BudgetHealth.onTrack => AppColors.success,
      BudgetHealth.warning => AppColors.warning,
      BudgetHealth.overLimit => AppColors.error,
    };

    return PremiumCard(
      color: AppColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(budget.categoryName, style: textTheme.titleMedium),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  AppFormatters.percentage(budget.progress),
                  style: textTheme.labelLarge?.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: budget.progress.clamp(0, 1),
            minHeight: 10,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: AppColors.lightPurple,
            color: statusColor,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Allocated',
                  value: AppFormatters.currency(
                    budget.limitAmount,
                    currencyCode: currencyCode,
                  ),
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Spent',
                  value: AppFormatters.currency(
                    budget.spentAmount,
                    currencyCode: currencyCode,
                  ),
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Remaining',
                  value: AppFormatters.currency(
                    budget.remainingAmount,
                    currencyCode: currencyCode,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
