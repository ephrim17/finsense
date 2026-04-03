import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/finance_defaults.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state_card.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../profile/presentation/controllers/preferences_providers.dart';
import '../providers/report_providers.dart';
import '../widgets/report_bar_chart.dart';
import '../widgets/report_donut_chart.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int? _selectedCategoryIndex;

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(reportSnapshotProvider);
    final viewMode = ref.watch(reportViewModeProvider);
    final chartMode = ref.watch(reportChartModeProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final currencyCode =
        ref.watch(userPreferencesProvider).valueOrNull?.currencyCode ??
        user?.currencyCode ??
        FinanceDefaults.defaultCurrencyCode;
    final isExpenseMode = viewMode == ReportViewMode.expenses;
    final activeCategorySpend = isExpenseMode
        ? report.expenseCategorySpend
        : report.incomeCategorySpend;
    final activeTotal = isExpenseMode
        ? report.totalExpenses
        : report.totalIncome;
    final reportSummaryAsync = ref.watch(reportAiSummaryProvider(viewMode));
    final categories = activeCategorySpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final selectedEntry = _selectedCategoryIndex != null &&
            _selectedCategoryIndex! >= 0 &&
            _selectedCategoryIndex! < categories.length
        ? categories[_selectedCategoryIndex!]
        : null;
    final selectedValue = selectedEntry?.value ?? activeTotal;
    final selectedLabel = selectedEntry?.key ??
        (isExpenseMode ? 'Total Expenses' : 'Total Income');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            Row(
              children: [
                Text(
                  'Report',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFECE7F5)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        AppFormatters.shortMonth(DateTime.now()),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            PremiumCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F1F5),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() {
                                  ref
                                          .read(reportViewModeProvider.notifier)
                                          .state =
                                      ReportViewMode.expenses;
                                  _selectedCategoryIndex = null;
                                }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isExpenseMode
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: isExpenseMode
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x12000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Expenses',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isExpenseMode
                                      ? AppColors.textPrimary
                                      : const Color(0xFF756F84),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() {
                                  ref
                                          .read(reportViewModeProvider.notifier)
                                          .state =
                                      ReportViewMode.income;
                                  _selectedCategoryIndex = null;
                                }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isExpenseMode
                                    ? Colors.transparent
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: isExpenseMode
                                    ? null
                                    : const [
                                        BoxShadow(
                                          color: Color(0x12000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                              ),
                              child: Text(
                                'Income',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isExpenseMode
                                      ? const Color(0xFF756F84)
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        isExpenseMode ? 'Expenses Report' : 'Income Report',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() {
                          ref.read(reportChartModeProvider.notifier).state =
                              ReportChartMode.bar;
                        }),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: chartMode == ReportChartMode.bar
                                ? AppColors.lightPurple
                                : const Color(0xFFF6F1FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.bar_chart_rounded,
                            color: chartMode == ReportChartMode.bar
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() {
                          ref.read(reportChartModeProvider.notifier).state =
                              ReportChartMode.pie;
                        }),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: chartMode == ReportChartMode.pie
                                ? AppColors.lightPurple
                                : const Color(0xFFF6F1FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.pie_chart_rounded,
                            color: chartMode == ReportChartMode.pie
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (chartMode == ReportChartMode.pie)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ReportDonutChart(
                          entries: categories,
                          selectedIndex: _selectedCategoryIndex,
                          animationKey: '${viewMode.name}-${chartMode.name}-${categories.length}',
                          onSectionTap: (index) {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                        ),
                        IgnorePointer(
                          child: SizedBox(
                            width: 132,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedLabel,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    AppFormatters.currency(
                                      selectedValue,
                                      currencyCode: currencyCode,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 30,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isExpenseMode
                                        ? 'Total Expenses'
                                        : 'Total Income',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppFormatters.currency(
                                      activeTotal,
                                      currencyCode: currencyCode,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ReportBarChart(
                          entries: categories.take(5).toList(),
                          animationKey: '${viewMode.name}-${chartMode.name}-${categories.length}',
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: selectedEntry == null ||
                              chartMode != ReportChartMode.pie
                          ? 0
                          : 1,
                      child: selectedEntry == null ||
                              chartMode != ReportChartMode.pie
                          ? const SizedBox.shrink()
                          : Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: reportCategoryColorForIndex(
                                  _selectedCategoryIndex!,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: reportCategoryColorForIndex(
                                    _selectedCategoryIndex!,
                                  ).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: reportCategoryColorForIndex(
                                        _selectedCategoryIndex!,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.pie_chart_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedEntry.key,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${((selectedEntry.value / activeTotal) * 100).toStringAsFixed(0)}% of ${isExpenseMode ? 'expenses' : 'income'}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    AppFormatters.currency(
                                      selectedEntry.value,
                                      currencyCode: currencyCode,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        selectedEntry == null
                            ? (isExpenseMode ? 'All Expenses' : 'All Income')
                            : 'Selected Category',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        selectedEntry == null
                            ? 'Total  ${AppFormatters.currency(activeTotal, currencyCode: currencyCode)}'
                            : AppFormatters.currency(
                                selectedEntry.value,
                                currencyCode: currencyCode,
                              ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ReportAiSummaryCard(
              summaryAsync: reportSummaryAsync,
              isExpenseMode: isExpenseMode,
            ),
            const SizedBox(height: 16),
            if (activeCategorySpend.isEmpty)
              EmptyStateCard(
                title: isExpenseMode
                    ? 'Not enough expense data yet'
                    : 'Not enough income data yet',
                message: isExpenseMode
                    ? 'Once expenses arrive, category analytics will appear here.'
                    : 'Once income arrives, category analytics will appear here.',
                icon: Icons.pie_chart_outline_rounded,
              )
            else
              ...categories
                  .take(4)
                  .toList()
                  .asMap()
                  .entries
                  .map(
                    (item) {
                      final index = item.key;
                      final entry = item.value;
                      final accent = reportCategoryColorForIndex(index);
                      return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PremiumCard(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    Icons.category_rounded,
                                    color: accent,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${((entry.value / activeTotal) * 100).toStringAsFixed(0)}% of total',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      AppFormatters.currency(
                                        entry.value,
                                        currencyCode: currencyCode,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        '+12%',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: activeTotal == 0
                                    ? 0
                                    : entry.value / activeTotal,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFF0EDF5),
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class _ReportAiSummaryCard extends ConsumerWidget {
  const _ReportAiSummaryCard({
    required this.summaryAsync,
    required this.isExpenseMode,
  });

  final AsyncValue summaryAsync;
  final bool isExpenseMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PremiumCard(
      child: summaryAsync.when(
        loading: () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI Report Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const LinearProgressIndicator(minHeight: 8),
            const SizedBox(height: 12),
            Text(
              'FinSense is reading your ${isExpenseMode ? 'expense' : 'income'} report...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        error: (error, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEE7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: Color(0xFFED6A3B),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI Report Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'The report summary is unavailable right now.',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
        data: (payload) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D5DF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Report Summary',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isExpenseMode
                            ? 'Gemini take on your current expense mix'
                            : 'Gemini take on your current income mix',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              payload.headline,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              payload.summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            if (payload.actionItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        payload.actionItems.first,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
