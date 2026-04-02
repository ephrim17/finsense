import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/finance_defaults.dart';
import '../../../../core/enums/finance_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../budgets/domain/entities/budget_plan.dart';
import '../../../budgets/presentation/controllers/budget_providers.dart';
import '../../../goals/domain/entities/savings_goal.dart';
import '../../../goals/presentation/controllers/goals_providers.dart';
import '../../../profile/presentation/controllers/preferences_providers.dart';
import '../../domain/entities/ai_insight_payload.dart';
import '../../domain/entities/transaction_record.dart';
import '../controllers/financial_insights_providers.dart';
import '../controllers/transaction_providers.dart';

class TransactionsAiInsightsScreen extends ConsumerStatefulWidget {
  const TransactionsAiInsightsScreen({super.key});

  @override
  ConsumerState<TransactionsAiInsightsScreen> createState() =>
      _TransactionsAiInsightsScreenState();
}

class _TransactionsAiInsightsScreenState
    extends ConsumerState<TransactionsAiInsightsScreen> {
  final _coachController = TextEditingController();
  AiInsightPayload? _payload;
  String _activeMode = 'overview';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runMode('overview');
    });
  }

  @override
  void dispose() {
    _coachController.dispose();
    super.dispose();
  }

  Future<void> _runMode(String mode, {String? userPrompt}) async {
    final transactions = ref.read(transactionsProvider).valueOrNull ?? const [];
    final budgets = ref.read(budgetsProvider).valueOrNull ?? const [];
    final goals = ref.read(goalsProvider).valueOrNull ?? const [];
    final user = ref.read(currentUserProvider).valueOrNull;
    final currencyCode =
        ref.read(userPreferencesProvider).valueOrNull?.currencyCode ??
        user?.currencyCode ??
        FinanceDefaults.defaultCurrencyCode;

    setState(() {
      _activeMode = mode;
      _isLoading = true;
      _error = null;
    });

    final service = ref.read(financialInsightsServiceProvider);

    try {
      final payload = switch (mode) {
        'weekly' => await service.generateWeeklySummary(
          transactions: transactions,
          budgets: budgets,
          goals: goals,
          currencyCode: currencyCode,
        ),
        'budget' => await service.generateBudgetSuggestions(
          transactions: transactions,
          budgets: budgets,
          goals: goals,
          currencyCode: currencyCode,
        ),
        'goals' => await service.generateGoalPlan(
          transactions: transactions,
          budgets: budgets,
          goals: goals,
          currencyCode: currencyCode,
        ),
        'coach' => await service.askCoach(
          userPrompt: userPrompt ?? _coachController.text.trim(),
          transactions: transactions,
          budgets: budgets,
          goals: goals,
          currencyCode: currencyCode,
        ),
        _ => await service.generateOverviewInsights(
          transactions: transactions,
          budgets: budgets,
          goals: goals,
          currencyCode: currencyCode,
        ),
      };

      if (!mounted) return;
      setState(() {
        _payload = payload;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _payload = null;
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider).valueOrNull ?? const [];
    final budgets = ref.watch(budgetsProvider).valueOrNull ?? const [];
    final goals = ref.watch(goalsProvider).valueOrNull ?? const [];
    final user = ref.watch(currentUserProvider).valueOrNull;
    final currencyCode =
        ref.watch(userPreferencesProvider).valueOrNull?.currencyCode ??
        user?.currencyCode ??
        FinanceDefaults.defaultCurrencyCode;

    return AppScaffold(
      title: 'FinSense Insights',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => _runMode(_activeMode),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: ListView(
        children: [
          const _AiHeaderCard(),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ModeChip(
                label: 'Overall Health',
                selected: _activeMode == 'overview',
                onTap: () => _runMode('overview'),
              ),
              _ModeChip(
                label: 'Weekly Summary',
                selected: _activeMode == 'weekly',
                onTap: () => _runMode('weekly'),
              ),
              _ModeChip(
                label: 'Budget Rescue',
                selected: _activeMode == 'budget',
                onTap: () => _runMode('budget'),
              ),
              _ModeChip(
                label: 'Goal Planner',
                selected: _activeMode == 'goals',
                onTap: () => _runMode('goals'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InsightVisualDashboard(
            transactions: transactions,
            budgets: budgets,
            goals: goals,
            currencyCode: currencyCode,
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask FinSense coach',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _coachController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        'Ask something like: How can I cut dining spend this month?',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickPromptButton(
                      label: 'How can I save more this month?',
                      onTap: () {
                        _coachController.text =
                            'How can I save more this month?';
                        _runMode('coach', userPrompt: _coachController.text);
                      },
                    ),
                    _QuickPromptButton(
                      label: 'What is my worst spending habit?',
                      onTap: () {
                        _coachController.text =
                            'What is my worst spending habit?';
                        _runMode('coach', userPrompt: _coachController.text);
                      },
                    ),
                    _QuickPromptButton(
                      label: 'How should I fund my goals?',
                      onTap: () {
                        _coachController.text =
                            'How should I fund my goals with my current cash flow?';
                        _runMode('coach', userPrompt: _coachController.text);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _runMode('coach', userPrompt: _coachController.text.trim()),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Ask FinSense'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: _buildInsightBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightBody(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8F5), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3D7CE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEE7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFED6A3B),
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'FinSense Insights is taking a quick pause',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () => _runMode(_activeMode),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _runMode('overview'),
                  icon: const Icon(Icons.insights_rounded),
                  label: const Text('Load Overview'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final payload = _payload;
    if (payload == null) {
      return const Text('No insights yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InsightHero(
          headline: payload.headline,
          summary: payload.summary,
          mood: payload.mood,
        ),
        if (payload.highlights.isNotEmpty) ...[
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 900
                  ? 4
                  : width >= 680
                  ? 3
                  : 2;
              final childAspectRatio = width < 420
                  ? 0.62
                  : width < 520
                  ? 0.72
                  : 0.9;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payload.highlights.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  return _InsightHighlightCard(
                    highlight: payload.highlights[index],
                  );
                },
              );
            },
          ),
        ],
        if (payload.sections.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...payload.sections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == payload.sections.length - 1 ? 0 : 14,
              ),
              child: _InsightSectionCard(section: section),
            );
          }),
        ],
        if (payload.actionItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ActionPlanCard(items: payload.actionItems),
        ],
      ],
    );
  }
}

class _AiHeaderCard extends StatelessWidget {
  const _AiHeaderCard();

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial health assistant',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'See overall health, weekly summaries, budget rescue ideas, goal planning, and coaching from your real app data.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _InsightVisualDashboard extends StatelessWidget {
  const _InsightVisualDashboard({
    required this.transactions,
    required this.budgets,
    required this.goals,
    required this.currencyCode,
  });

  final List<TransactionRecord> transactions;
  final List<BudgetPlan> budgets;
  final List<SavingsGoal> goals;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final income = transactions
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expenses = transactions
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final net = income - expenses;
    final score = _financialHealthScore(
      income: income,
      expenses: expenses,
      budgets: budgets,
      goals: goals,
    );
    final topCategories = _topExpenseCategories(transactions);
    final riskyBudgets = budgets
        .where((item) => item.health != BudgetHealth.onTrack)
        .toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));
    final activeGoals = goals.toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Health Score',
                value: '$score/100',
                caption: score >= 75
                    ? 'Strong money habits'
                    : score >= 55
                    ? 'Stable with room to grow'
                    : 'Needs attention',
                accent: score >= 75
                    ? AppColors.success
                    : score >= 55
                    ? AppColors.warning
                    : AppColors.error,
                icon: Icons.favorite_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Net Balance',
                value: AppFormatters.currency(net, currencyCode: currencyCode),
                caption: net >= 0 ? 'You are cash-flow positive' : 'Expenses exceed income',
                accent: net >= 0 ? AppColors.success : AppColors.error,
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cash Flow Snapshot',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _FlowBar(
                label: 'Income',
                value: income,
                maxValue: income > expenses ? income : expenses,
                color: AppColors.success,
                valueLabel: AppFormatters.currency(income, currencyCode: currencyCode),
              ),
              const SizedBox(height: 10),
              _FlowBar(
                label: 'Expenses',
                value: expenses,
                maxValue: income > expenses ? income : expenses,
                color: AppColors.primary,
                valueLabel: AppFormatters.currency(expenses, currencyCode: currencyCode),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Spending',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (topCategories.isEmpty)
                      const Text('No expense data yet.')
                    else
                      ...topCategories.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CategoryBar(
                            label: entry.key,
                            value: entry.value,
                            maxValue: topCategories.first.value,
                            valueLabel: AppFormatters.currency(
                              entry.value,
                              currencyCode: currencyCode,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Radar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (riskyBudgets.isEmpty)
                      const Text('All budgets look healthy.')
                    else
                      ...riskyBudgets.take(3).map(
                        (budget) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RiskPill(
                            label: budget.categoryName,
                            status: budget.health,
                            progress: budget.progress,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goal Momentum',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              if (activeGoals.isEmpty)
                const Text('Create a goal to unlock planning insights.')
              else
                ...activeGoals.take(3).map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _GoalMomentumTile(
                      goal: goal,
                      currencyCode: currencyCode,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  int _financialHealthScore({
    required double income,
    required double expenses,
    required List<BudgetPlan> budgets,
    required List<SavingsGoal> goals,
  }) {
    var score = 50.0;
    if (income > 0) {
      final savingsRate = ((income - expenses) / income).clamp(-1, 1);
      score += savingsRate * 30;
    }
    final overLimitCount = budgets.where((item) => item.health == BudgetHealth.overLimit).length;
    final warningCount = budgets.where((item) => item.health == BudgetHealth.warning).length;
    score -= overLimitCount * 12;
    score -= warningCount * 5;
    final completedGoals = goals.where((item) => item.progress >= 1).length;
    score += completedGoals * 4;
    return score.clamp(0, 100).round();
  }

  List<MapEntry<String, double>> _topExpenseCategories(
    List<TransactionRecord> items,
  ) {
    final totals = <String, double>{};
    for (final transaction in items.where((item) => item.type == TransactionType.expense)) {
      totals.update(
        transaction.categoryName,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(4).toList();
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.14), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _FlowBar extends StatelessWidget {
  const _FlowBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.valueLabel,
  });

  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            Text(valueLabel, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 12,
            backgroundColor: AppColors.lightPurple,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.valueLabel,
  });

  final String label;
  final double value;
  final double maxValue;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
            Text(valueLabel, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: AppColors.lavenderSurface,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _RiskPill extends StatelessWidget {
  const _RiskPill({
    required this.label,
    required this.status,
    required this.progress,
  });

  final String label;
  final BudgetHealth status;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      BudgetHealth.onTrack => AppColors.success,
      BudgetHealth.warning => AppColors.warning,
      BudgetHealth.overLimit => AppColors.error,
    };

    final statusText = switch (status) {
      BudgetHealth.onTrack => 'On track',
      BudgetHealth.warning => 'Warning',
      BudgetHealth.overLimit => 'Over limit',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                statusText,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1).toDouble(),
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalMomentumTile extends StatelessWidget {
  const _GoalMomentumTile({required this.goal, required this.currencyCode});

  final SavingsGoal goal;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(goal.progress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${AppFormatters.currency(goal.currentAmount, currencyCode: currencyCode)} of ${AppFormatters.currency(goal.targetAmount, currencyCode: currencyCode)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 9,
              backgroundColor: AppColors.lavenderSurface,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightHero extends StatelessWidget {
  const _InsightHero({
    required this.headline,
    required this.summary,
    required this.mood,
  });

  final String headline;
  final String summary;
  final String mood;

  @override
  Widget build(BuildContext context) {
    final toneColor = switch (mood.toLowerCase()) {
      'strong' || 'positive' => AppColors.success,
      'warning' || 'watch' => AppColors.warning,
      'critical' || 'risk' => AppColors.error,
      _ => Colors.white,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D5DF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'AI Financial Readout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            headline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: toneColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              'Mood: ${mood.isEmpty ? 'steady' : mood}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightSectionCard extends StatelessWidget {
  const _InsightSectionCard({required this.section});

  final AiInsightSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...section.items.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      line,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightHighlightCard extends StatelessWidget {
  const _InsightHighlightCard({required this.highlight});

  final AiInsightHighlight highlight;

  @override
  Widget build(BuildContext context) {
    final sentimentColor = switch (highlight.sentiment.toLowerCase()) {
      'positive' || 'good' => AppColors.success,
      'warning' || 'watch' => AppColors.warning,
      'negative' || 'risk' => AppColors.error,
      _ => AppColors.primary,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            highlight.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              highlight.value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: sentimentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              highlight.sentiment,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: sentimentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              highlight.insight,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.4),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPlanCard extends StatelessWidget {
  const _ActionPlanCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F4FF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Action Plan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: entry.key == items.length - 1 ? 0 : 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _QuickPromptButton extends StatelessWidget {
  const _QuickPromptButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(label),
    );
  }
}
