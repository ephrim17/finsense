import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

const reportCategoryPalette = <Color>[
  AppColors.primary,
  Color(0xFF4F7CFF),
  Color(0xFFFF8A5B),
  Color(0xFF2DBE8D),
  Color(0xFFF2C14E),
  Color(0xFFAE8EFF),
  Color(0xFFEF5DA8),
  Color(0xFF5CC8FF),
];

Color reportCategoryColorForIndex(int index) {
  return reportCategoryPalette[index % reportCategoryPalette.length];
}

class ReportDonutChart extends StatelessWidget {
  const ReportDonutChart({
    super.key,
    required this.entries,
    this.selectedIndex,
    this.onSectionTap,
    this.animationKey,
  });

  final List<MapEntry<String, double>> entries;
  final int? selectedIndex;
  final ValueChanged<int?>? onSectionTap;
  final Object? animationKey;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(animationKey ?? entries.length),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        return SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 70,
              sectionsSpace: 4,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (onSectionTap == null) return;
                  final sectionIndex = response
                      ?.touchedSection
                      ?.touchedSectionIndex;
                  if (sectionIndex == null) {
                    if (event is FlTapUpEvent || event is FlPanEndEvent) {
                      onSectionTap!(null);
                    }
                    return;
                  }

                  onSectionTap!(
                    selectedIndex == sectionIndex ? null : sectionIndex,
                  );
                },
              ),
              sections: List.generate(entries.length, (index) {
                final entry = entries[index];
                final isSelected = selectedIndex == index;
                final hasSelection = selectedIndex != null;
                final baseColor = reportCategoryColorForIndex(index);
                return PieChartSectionData(
                  value: entry.value * progress,
                  radius: isSelected ? 38 : 30,
                  color: hasSelection && !isSelected
                      ? baseColor.withValues(alpha: 0.28)
                      : baseColor,
                  title: '',
                  badgeWidget: isSelected
                      ? Transform.scale(
                          scale: progress,
                          child: const Icon(
                            Icons.touch_app_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        )
                      : null,
                  badgePositionPercentageOffset: 1.08,
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
