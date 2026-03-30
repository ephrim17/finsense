import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/finance_defaults.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state_card.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../domain/entities/savings_goal.dart';
import '../../../profile/presentation/controllers/preferences_providers.dart';
import '../controllers/goals_providers.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider).valueOrNull ?? const [];
    final user = ref.watch(currentUserProvider).valueOrNull;
    final currencyCode =
        ref.watch(userPreferencesProvider).valueOrNull?.currencyCode ??
        user?.currencyCode ??
        FinanceDefaults.defaultCurrencyCode;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            Row(
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded),
                const SizedBox(width: 12),
                Text(
                  'My Plan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _showCreateDialog(context, ref),
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.open_in_new_rounded),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Text(
                  'Goals',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF8E879D)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (goals.isEmpty)
              const EmptyStateCard(
                title: 'No savings goals yet',
                message:
                    'Create a goal for a car, education, or emergency fund.',
                icon: Icons.flag_rounded,
              )
            else
              ...goals
                  .take(1)
                  .map(
                    (goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _GoalHeroCard(
                        goal: goal,
                        currencyCode: currencyCode,
                      ),
                    ),
                  ),
            Row(
              children: [
                Text(
                  'Budgets',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF8E879D)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...goals
                .skip(1)
                .map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CompactPlanCard(
                      goal: goal,
                      currencyCode: currencyCode,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider).valueOrNull;

    await showDialog<void>(
      context: context,
      barrierColor: const Color(0x660E0A19),
      builder: (context) {
        return _CreateGoalDialog(
          enabled: user != null,
          onSave: (title, targetAmount, currentAmount) {
            if (user == null) {
              return;
            }
            ref
                .read(goalActionControllerProvider.notifier)
                .save(
                  userId: user.id,
                  title: title,
                  targetAmount: targetAmount,
                  currentAmount: currentAmount,
                  icon: 'target',
                  color: '#8B5CF6',
                );
          },
        );
      },
    );
  }
}

class _CreateGoalDialog extends StatefulWidget {
  const _CreateGoalDialog({required this.enabled, required this.onSave});

  final bool enabled;
  final void Function(String title, double targetAmount, double currentAmount)
  onSave;

  @override
  State<_CreateGoalDialog> createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends State<_CreateGoalDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;
  late final TextEditingController _currentController;
  late final FocusNode _titleFocusNode;
  late final FocusNode _targetFocusNode;
  late final FocusNode _currentFocusNode;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _targetController = TextEditingController();
    _currentController = TextEditingController(text: '0');
    _titleFocusNode = FocusNode();
    _targetFocusNode = FocusNode();
    _currentFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _titleFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _titleFocusNode.dispose();
    _targetFocusNode.dispose();
    _currentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.fromLTRB(16, 16, 16, viewInsets.bottom + 12),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 420,
                maxHeight: screenHeight * 0.78,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFBF8FF), Color(0xFFF0E8FF)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1E000000),
                      blurRadius: 34,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
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
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9E77FF), Color(0xFF7C4DFF)],
                              ),
                            ),
                            child: const Icon(
                              Icons.flag_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Goal',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Set a target and start tracking your next milestone.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: const Color(0xFF7B758C),
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _GoalModalField(
                        label: 'Goal title',
                        hintText: 'Emergency fund',
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _targetFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: 14),
                      _GoalModalField(
                        label: 'Target amount',
                        hintText: '500000',
                        controller: _targetController,
                        focusNode: _targetFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _currentFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: 14),
                      _GoalModalField(
                        label: 'Current amount',
                        hintText: '0',
                        controller: _currentController,
                        focusNode: _currentFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSave(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                foregroundColor: const Color(0xFF8B5CF6),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B5CF6),
                                    Color(0xFF7C4DFF),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x338B5CF6),
                                    blurRadius: 18,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: widget.enabled ? _handleSave : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.transparent,
                                  minimumSize: const Size.fromHeight(58),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: const Text(
                                  'Save Goal',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    final targetAmount = double.tryParse(_targetController.text.trim()) ?? 0;
    final currentAmount = double.tryParse(_currentController.text.trim()) ?? 0;

    widget.onSave(title, targetAmount, currentAmount);
    Navigator.of(context).pop();
  }
}

class _GoalModalField extends StatelessWidget {
  const _GoalModalField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF7B758C),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE4DAF7)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalHeroCard extends StatelessWidget {
  const _GoalHeroCard({required this.goal, required this.currencyCode});

  final SavingsGoal goal;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.adjust_rounded,
                  size: 18,
                  color: Color(0xFFFF7C5C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'View All',
                      style: TextStyle(color: Color(0xFF8E879D)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert_rounded, color: Color(0xFF8E879D)),
            ],
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF8E879D)),
              children: [
                TextSpan(
                  text: AppFormatters.currency(
                    goal.currentAmount,
                    currencyCode: currencyCode,
                  ),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text:
                      ' Out of ${AppFormatters.currency(goal.targetAmount, currencyCode: currencyCode)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: goal.progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: const Color(0xFFFFE7E3),
              color: const Color(0xFFFF7C5C),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Your Progress',
                style: TextStyle(color: Color(0xFF8E879D)),
              ),
              const Spacer(),
              Text(
                '${AppFormatters.currency(goal.targetAmount - goal.currentAmount, currencyCode: currencyCode)} Left',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6A4B),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "You're 30% behind schedule and off target.",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactPlanCard extends StatelessWidget {
  const _CompactPlanCard({required this.goal, required this.currencyCode});

  final SavingsGoal goal;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final progress = (goal.progress * 100).toStringAsFixed(0);
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.savings_rounded, color: Color(0xFFFF8A63)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppFormatters.currency(goal.currentAmount, currencyCode: currencyCode)} of ${AppFormatters.currency(goal.targetAmount, currencyCode: currencyCode)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFB6A2), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              '$progress%',
              style: const TextStyle(
                color: Color(0xFFFF7C5C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
