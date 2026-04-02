import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/finance_defaults.dart';
import '../../../../core/enums/finance_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/empty_state_card.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../budgets/presentation/controllers/budget_providers.dart';
import '../../../budgets/presentation/widgets/budget_progress_card.dart';
import '../../../goals/presentation/controllers/goals_providers.dart';
import '../../../goals/presentation/widgets/goal_progress_card.dart';
import '../../../profile/presentation/controllers/preferences_providers.dart';
import '../../../transactions/presentation/controllers/transaction_providers.dart';
import '../../../../shared/widgets/app_text_field.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider).valueOrNull ?? const [];
    final goals = ref.watch(goalsProvider).valueOrNull ?? const [];
    final user = ref.watch(currentUserProvider).valueOrNull;
    final currencyCode =
        ref.watch(userPreferencesProvider).valueOrNull?.currencyCode ??
        user?.currencyCode ??
        FinanceDefaults.defaultCurrencyCode;

    return AppScaffold(
      title: 'Plan',
      body: ListView(
        children: [
          SectionHeader(
            title: 'Goals',
            subtitle: 'Keep savings goals and budgets together in one place',
            actionLabel: 'Add',
            onActionTap: () => _showCreateGoalDialog(context, ref),
          ),
          const SizedBox(height: 12),
          if (goals.isEmpty)
            const EmptyStateCard(
              title: 'No savings goals yet',
              message:
                  'Create a goal for transport, emergency funds, or travel.',
              icon: Icons.flag_rounded,
            )
          else
            ...goals.map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GoalProgressCard(
                  goal: goal,
                  currencyCode: currencyCode,
                ),
              ),
            ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Budgets',
            subtitle: 'Track category limits alongside your goals',
            actionLabel: 'Add',
            onActionTap: () => _showCreateBudgetDialog(context, ref),
          ),
          const SizedBox(height: 12),
          if (budgets.isEmpty)
            const EmptyStateCard(
              title: 'No budgets configured',
              message:
                  'Add monthly category budgets so spending progress stays visible.',
              icon: Icons.account_balance_wallet_rounded,
            )
          else
            ...budgets.map(
              (budget) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BudgetProgressCard(
                  budget: budget,
                  currencyCode: currencyCode,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showCreateBudgetDialog(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateBudgetSheet(ref: ref),
    );
  }

  Future<void> _showCreateGoalDialog(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateGoalSheet(ref: ref),
    );
  }
}

class _CreateGoalSheet extends ConsumerStatefulWidget {
  const _CreateGoalSheet({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends ConsumerState<_CreateGoalSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;
  late final TextEditingController _currentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _targetController = TextEditingController();
    _currentController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.ref.read(currentUserProvider).valueOrNull;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F4FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7CEE7),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D5DF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Goal',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Set a target and track your next milestone in the same polished flow as budgets.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                PremiumCard(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF8B5CF6),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tip: start with the final target amount and today\'s saved amount. FinSense will handle the progress view from there.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AppTextField(label: 'Goal title', controller: _titleController),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Target amount',
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Current amount',
                  controller: _currentController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: user == null
                            ? null
                            : () {
                                widget.ref
                                    .read(goalActionControllerProvider.notifier)
                                    .save(
                                      userId: user.id,
                                      title: _titleController.text.trim(),
                                      targetAmount:
                                          double.tryParse(
                                            _targetController.text.trim(),
                                          ) ??
                                          0,
                                      currentAmount:
                                          double.tryParse(
                                            _currentController.text.trim(),
                                          ) ??
                                          0,
                                      icon: 'target',
                                      color: '#8B5CF6',
                                    );
                                Navigator.of(context).pop();
                              },
                        child: const Text('Save Goal'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateBudgetSheet extends ConsumerStatefulWidget {
  const _CreateBudgetSheet({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_CreateBudgetSheet> createState() => _CreateBudgetSheetState();
}

class _CreateBudgetSheetState extends ConsumerState<_CreateBudgetSheet> {
  late final TextEditingController _limitController;
  String _selectedCategory = FinanceDefaults.expenseCategories.first;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController();
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.ref.read(currentUserProvider).valueOrNull;
    final budgets = ref.watch(budgetsProvider).valueOrNull ?? const [];
    final transactions = ref.watch(transactionsProvider).valueOrNull ?? const [];
    final profile = ref.watch(currentUserProvider).valueOrNull;
    final currencyCode =
        ref.watch(userPreferencesProvider).valueOrNull?.currencyCode ??
        profile?.currencyCode ??
        FinanceDefaults.defaultCurrencyCode;

    final existingBudget = budgets
        .where((budget) => budget.categoryName == _selectedCategory)
        .firstOrNull;
    final insight = _BudgetCategoryInsight.fromData(
      category: _selectedCategory,
      transactions: transactions,
      budgets: budgets,
      currencyCode: currencyCode,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F4FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7CEE7),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D5DF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Budget',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Choose a category and set a realistic monthly limit with FinSense guidance.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Choose category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: FinanceDefaults.expenseCategories.map((category) {
                    final visual = _planCategoryVisual(category);
                    final selected = category == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? visual.color.withValues(alpha: 0.15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? visual.color
                                : AppColors.divider,
                            width: selected ? 1.6 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(visual.icon, size: 18, color: visual.color),
                            const SizedBox(width: 8),
                            Text(
                              category,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: PremiumCard(
                    key: ValueKey(_selectedCategory),
                    color: insight.tint.withValues(alpha: 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: insight.tint),
                            const SizedBox(width: 8),
                            Text(
                              'FinSense insight',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: insight.tint,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          insight.summary,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        if (insight.suggestedLimit > 0)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Suggested monthly limit',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _limitController.text = insight.suggestedLimit
                                      .toStringAsFixed(0);
                                },
                                child: Text(
                                  AppFormatters.currency(
                                    insight.suggestedLimit,
                                    currencyCode: currencyCode,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Monthly limit',
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                ),
                if (existingBudget != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'A budget already exists for $_selectedCategory. Saving here will update it.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: user == null
                            ? null
                            : () {
                                widget.ref
                                    .read(
                                      budgetActionControllerProvider.notifier,
                                    )
                                    .save(
                                      userId: user.id,
                                      id: existingBudget?.id,
                                      categoryName: _selectedCategory,
                                      limitAmount:
                                          double.tryParse(
                                            _limitController.text.trim(),
                                          ) ??
                                          0,
                                      spentAmount:
                                          existingBudget?.spentAmount ?? 0,
                                    );
                                Navigator.of(context).pop();
                              },
                        child: const Text('Save Budget'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetCategoryInsight {
  const _BudgetCategoryInsight({
    required this.summary,
    required this.suggestedLimit,
    required this.tint,
  });

  final String summary;
  final double suggestedLimit;
  final Color tint;

  factory _BudgetCategoryInsight.fromData({
    required String category,
    required List<dynamic> transactions,
    required List<dynamic> budgets,
    required String currencyCode,
  }) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final categoryTransactions = transactions
        .where(
          (item) =>
              item.type == TransactionType.expense &&
              item.categoryName == category &&
              !item.transactionDate.isBefore(startOfMonth),
        )
        .toList();

    final spentThisMonth = categoryTransactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final transactionCount = categoryTransactions.length;
    final existingBudget = budgets
        .where((budget) => budget.categoryName == category)
        .firstOrNull;
    final visual = _planCategoryVisual(category);

    if (spentThisMonth <= 0) {
      return _BudgetCategoryInsight(
        summary:
            'No expense has been logged in $category this month yet. Start with a gentle limit and tighten it after a few real transactions.',
        suggestedLimit: 2500,
        tint: visual.color,
      );
    }

    final suggestedLimit = spentThisMonth * 1.18;
    final existingBudgetText = existingBudget == null
        ? ''
        : ' Current budget: ${AppFormatters.currency(existingBudget.limitAmount, currencyCode: currencyCode)}.';

    return _BudgetCategoryInsight(
      summary:
          'You already spent ${AppFormatters.currency(spentThisMonth, currencyCode: currencyCode)} across $transactionCount ${transactionCount == 1 ? 'transaction' : 'transactions'} in $category this month.$existingBudgetText A realistic budget can sit a little above that pace.',
      suggestedLimit: suggestedLimit,
      tint: visual.color,
    );
  }
}

class _PlanCategoryVisual {
  const _PlanCategoryVisual({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

_PlanCategoryVisual _planCategoryVisual(String category) {
  switch (category) {
    case 'Groceries':
      return const _PlanCategoryVisual(
        icon: Icons.local_grocery_store_rounded,
        color: Color(0xFF2DBE8D),
      );
    case 'Food & Dining':
      return const _PlanCategoryVisual(
        icon: Icons.restaurant_rounded,
        color: Color(0xFFFF8A5B),
      );
    case 'Transport':
      return const _PlanCategoryVisual(
        icon: Icons.directions_car_filled_rounded,
        color: Color(0xFFF2C14E),
      );
    case 'Shopping':
      return const _PlanCategoryVisual(
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFFEF5DA8),
      );
    case 'Bills & Utilities':
      return const _PlanCategoryVisual(
        icon: Icons.receipt_long_rounded,
        color: Color(0xFF7E67D3),
      );
    case 'Rent':
      return const _PlanCategoryVisual(
        icon: Icons.home_rounded,
        color: Color(0xFF5CC8FF),
      );
    case 'Health':
      return const _PlanCategoryVisual(
        icon: Icons.favorite_rounded,
        color: Color(0xFFFF5A76),
      );
    case 'Entertainment':
      return const _PlanCategoryVisual(
        icon: Icons.movie_rounded,
        color: Color(0xFFAE8EFF),
      );
    case 'Travel':
      return const _PlanCategoryVisual(
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF4F7CFF),
      );
    case 'Education':
      return const _PlanCategoryVisual(
        icon: Icons.school_rounded,
        color: Color(0xFF3AA0FF),
      );
    case 'Family':
      return const _PlanCategoryVisual(
        icon: Icons.people_alt_rounded,
        color: Color(0xFFFB7185),
      );
    default:
      return const _PlanCategoryVisual(
        icon: Icons.wallet_rounded,
        color: AppColors.primary,
      );
  }
}
