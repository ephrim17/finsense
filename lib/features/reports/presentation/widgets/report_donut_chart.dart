import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

class ReportDonutChart extends StatelessWidget {
  const ReportDonutChart({super.key, required this.values});

  final Map<String, double> values;

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.toList();
    const palette = [
      AppColors.primary,
      Color(0xFFAE8EFF),
      Color(0xFFCBB8FF),
      Color(0xFF7E67D3),
      Color(0xFFDCCEFF),
    ];

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 60,
          sectionsSpace: 4,
          sections: List.generate(entries.length, (index) {
            final entry = entries[index];
            return PieChartSectionData(
              value: entry.value,
              radius: 34,
              color: palette[index % palette.length],
              title: '',
            );
          }),
        ),
      ),
    );
  }
}
