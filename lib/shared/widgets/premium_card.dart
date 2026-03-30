import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = AppColors.card,
    this.borderRadius = 28,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 32,
            offset: Offset(0, 18),
          ),
        ],
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
      ),
      child: child,
    );
  }
}
