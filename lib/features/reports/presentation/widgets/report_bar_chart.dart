import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import 'report_donut_chart.dart';

class ReportBarChart extends StatelessWidget {
  const ReportBarChart({
    super.key,
    required this.entries,
    this.animationKey,
  });

  final List<MapEntry<String, double>> entries;
  final Object? animationKey;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox(height: 220);
    }

    final maxValue = entries
        .map((entry) => entry.value)
        .fold<double>(0, (max, value) => value > max ? value : max);

    return TweenAnimationBuilder<double>(
      key: ValueKey(animationKey ?? entries.length),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        return SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 12),
            child: BarChart(
              BarChartData(
                maxY: maxValue == 0 ? 1 : maxValue * 1.2,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue == 0 ? 1 : maxValue / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFF0EDF5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= entries.length) {
                          return const SizedBox.shrink();
                        }

                        final label = entries[index].key;
                        final shortLabel = label.length > 8
                            ? '${label.substring(0, 8)}…'
                            : label;

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            shortLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1F1B2D),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final entry = entries[group.x.toInt()];
                      return BarTooltipItem(
                        '${entry.key}\n${entry.value.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: List.generate(entries.length, (index) {
                  final entry = entries[index];
                  final color = reportCategoryColorForIndex(index);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value * progress,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        color: color,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
