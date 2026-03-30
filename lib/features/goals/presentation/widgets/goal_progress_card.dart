import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../domain/entities/savings_goal.dart';

class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({
    super.key,
    required this.goal,
    required this.currencyCode,
  });

  final SavingsGoal goal;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(goal.title, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '${AppFormatters.currency(goal.currentAmount, currencyCode: currencyCode)} of ${AppFormatters.currency(goal.targetAmount, currencyCode: currencyCode)}',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: goal.progress.clamp(0, 1),
            minHeight: 10,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: AppColors.lightPurple,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            goal.deadline == null
                ? 'No deadline set'
                : 'Target by ${AppFormatters.longDate(goal.deadline!)}',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
