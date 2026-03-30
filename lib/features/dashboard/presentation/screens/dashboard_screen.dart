import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/finance_defaults.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/empty_state_card.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/summary_tile.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../budgets/presentation/controllers/budget_providers.dart';
import '../../../budgets/presentation/widgets/budget_progress_card.dart';
import '../../../goals/presentation/controllers/goals_providers.dart';
import '../../../goals/presentation/widgets/goal_progress_card.dart';
import '../../../profile/presentation/controllers/preferences_providers.dart';
import '../../../transactions/presentation/controllers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/transaction_list_item.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_balance_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final summary = ref.watch(dashboardSummaryProvider);
    final transactions =
        ref.watch(transactionsProvider).valueOrNull ?? const [];
    final budgets = ref.watch(budgetsProvider).valueOrNull ?? const [];
    final goals = ref.watch(goalsProvider).valueOrNull ?? const [];
    final insight = ref.watch(quickInsightProvider);
    final currencyCode =
        ref.watch(userPreferencesProvider).valueOrNull?.currencyCode ??
        user?.currencyCode ??
        FinanceDefaults.defaultCurrencyCode;

    return AppScaffold(
      body: ListView(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFD783),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      (user?.fullName.characters.firstOrNull ?? 'F')
                          .toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.fullName.split(' ').first ?? 'there'}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'A polished overview for ${AppFormatters.shortMonth(DateTime.now())}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _AddTransactionHeaderButton(
                onTap: () => context.push('/transactions/new'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DashboardBalanceCard(
            balance: summary.balance,
            periodLabel: AppFormatters.shortMonth(DateTime.now()),
            currencyCode: currencyCode,
            deltaText: summary.expenses > summary.income
                ? 'Expenses are ahead of last week'
                : 'Balance is trending positively this week',
          ),
          const SizedBox(height: 18),
          PremiumCard(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            borderRadius: 30,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Your Money',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            'Details',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    SummaryTile(
                      label: 'Income',
                      value: AppFormatters.currency(
                        summary.income,
                        currencyCode: currencyCode,
                      ),
                      icon: Icons.south_west_rounded,
                    ),
                    const SizedBox(width: 12),
                    SummaryTile(
                      label: 'Expenses',
                      value: AppFormatters.currency(
                        summary.expenses,
                        currencyCode: currencyCode,
                      ),
                      icon: Icons.north_east_rounded,
                      highlightColor: const Color(0xFFFFF1F2),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161214),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFD2B4FF),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Your insight is ready',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'Get Pro',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Transactions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.push_pin_outlined,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.history_toggle_off_rounded,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightPurple,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'For the Period',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Monday, 12 January, 2026',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                'Total  ${AppFormatters.currency(summary.expenses + summary.income, currencyCode: currencyCode)}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (transactions.isEmpty)
            const EmptyStateCard(
              title: 'No transactions yet',
              message:
                  'Create your first income or expense to bring the dashboard to life.',
              icon: Icons.receipt_long_rounded,
            )
          else
            PremiumCard(
              child: Column(
                children: transactions
                    .take(4)
                    .map(
                      (item) => TransactionListItem(
                        transaction: item,
                        currencyCode: currencyCode,
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'My Plan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.open_in_new_rounded, size: 20),
            ],
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Goals', actionLabel: 'View All'),
          const SizedBox(height: 12),
          if (goals.isEmpty)
            const EmptyStateCard(
              title: 'No goals yet',
              message:
                  'Add a vacation, emergency fund, or car goal to keep savings visible.',
              icon: Icons.flag_rounded,
            )
          else
            ...goals
                .take(1)
                .map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GoalProgressCard(
                      goal: goal,
                      currencyCode: currencyCode,
                    ),
                  ),
                ),
          const SectionHeader(title: 'Budgets', actionLabel: 'View All'),
          const SizedBox(height: 10),
          if (budgets.isEmpty)
            const EmptyStateCard(
              title: 'No budgets configured',
              message:
                  'Add monthly category budgets so spending progress stays visible.',
              icon: Icons.account_balance_wallet_rounded,
            )
          else
            ...budgets
                .take(2)
                .map(
                  (budget) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BudgetProgressCard(
                      budget: budget,
                      currencyCode: currencyCode,
                    ),
                  ),
                ),
          const SizedBox(height: 24),
          PremiumCard(
            color: AppColors.lightPurple,
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(insight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTransactionHeaderButton extends StatelessWidget {
  const _AddTransactionHeaderButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
