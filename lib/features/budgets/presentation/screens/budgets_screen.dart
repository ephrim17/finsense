import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/finance_defaults.dart';
import '../../../../core/enums/finance_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../profile/presentation/controllers/preferences_providers.dart';
import '../../domain/entities/budget_plan.dart';
import '../controllers/budget_providers.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider).valueOrNull ?? const [];
    final user = ref.watch(currentUserProvider).valueOrNull;
    final currencyCode =
        ref.watch(userPreferencesProvider).valueOrNull?.currencyCode ??
        user?.currencyCode ??
        FinanceDefaults.defaultCurrencyCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                _IconCircleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const Expanded(
                  child: Text(
                    'Categories',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                _IconCircleButton(
                  icon: Icons.add_rounded,
                  onTap: () => _showCreateDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _BudgetHeroCard(onTap: () => _showCreateDialog(context, ref)),
            const SizedBox(height: 18),
            if (budgets.isEmpty)
              const PremiumCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'No budgets yet. Add your first budget category to start tracking monthly limits.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              )
            else
              ...budgets.map(
                (budget) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _BudgetCategoryTile(
                    budget: budget,
                    currencyCode: currencyCode,
                    onDelete: user == null
                        ? null
                        : () => ref
                              .read(budgetActionControllerProvider.notifier)
                              .delete(userId: user.id, budgetId: budget.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final categoryController = TextEditingController();
    final limitController = TextEditingController();
    final user = ref.read(currentUserProvider).valueOrNull;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Category', controller: categoryController),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Monthly limit',
                controller: limitController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: user == null
                  ? null
                  : () {
                      ref
                          .read(budgetActionControllerProvider.notifier)
                          .save(
                            userId: user.id,
                            categoryName: categoryController.text.trim(),
                            limitAmount:
                                double.tryParse(limitController.text.trim()) ??
                                0,
                          );
                      Navigator.of(context).pop();
                    },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _BudgetHeroCard extends StatelessWidget {
  const _BudgetHeroCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                const Color(0xFFFFE7F3).withValues(alpha: 0.92),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Budget\nCategory',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Add New Categories'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const _BudgetHeroIllustration(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetHeroIllustration extends StatelessWidget {
  const _BudgetHeroIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138,
      height: 138,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 12,
            right: 14,
            child: _MiniBubble(icon: Icons.currency_bitcoin_rounded),
          ),
          Positioned(
            left: 6,
            bottom: 36,
            child: _MiniBubble(icon: Icons.pie_chart_rounded),
          ),
          Positioned(
            right: 6,
            bottom: 18,
            child: _MiniBubble(icon: Icons.analytics_rounded),
          ),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF42C4E8), Color(0xFF588CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF588CFF).withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          Positioned(
            top: 34,
            left: 18,
            child: _CoinDot(color: const Color(0xFFFFA541)),
          ),
          Positioned(
            top: 18,
            left: 52,
            child: _CoinDot(color: const Color(0xFFFFB55A)),
          ),
          Positioned(
            bottom: 22,
            right: 30,
            child: _CoinDot(color: const Color(0xFFFF914C)),
          ),
        ],
      ),
    );
  }
}

class _BudgetCategoryTile extends StatelessWidget {
  const _BudgetCategoryTile({
    required this.budget,
    required this.currencyCode,
    this.onDelete,
  });

  final BudgetPlan budget;
  final String currencyCode;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (budget.health) {
      BudgetHealth.overLimit =>
        'Over by ${AppFormatters.currency(-budget.remainingAmount, currencyCode: currencyCode)} this month',
      BudgetHealth.warning =>
        '${AppFormatters.currency(budget.spentAmount, currencyCode: currencyCode)} used so far',
      BudgetHealth.onTrack =>
        '${AppFormatters.currency(budget.remainingAmount, currencyCode: currencyCode)} left this month',
    };

    return PremiumCard(
      padding: const EdgeInsets.all(0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: budget.health == BudgetHealth.overLimit
                ? AppColors.error.withValues(alpha: 0.65)
                : AppColors.divider.withValues(alpha: 0.75),
            width: budget.health == BudgetHealth.overLimit ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FB),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _iconForCategory(budget.categoryName),
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    budget.categoryName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F3),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _iconForCategory(String category) {
    switch (category) {
      case 'Home':
      case 'Rent':
        return '🏠';
      case 'Shopping':
        return '🛍️';
      case 'Travel':
      case 'Transport':
        return '🚕';
      case 'Work':
      case 'Business':
        return '💼';
      case 'Health':
      case 'Fitness':
        return '🏋️';
      case 'Education':
        return '📚';
      case 'Groceries':
        return '🛒';
      case 'Food & Dining':
        return '🍜';
      default:
        return '💰';
    }
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }
}

class _MiniBubble extends StatelessWidget {
  const _MiniBubble({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 16, color: AppColors.primary),
    );
  }
}

class _CoinDot extends StatelessWidget {
  const _CoinDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const Icon(
        Icons.currency_rupee_rounded,
        size: 12,
        color: Colors.white,
      ),
    );
  }
}
