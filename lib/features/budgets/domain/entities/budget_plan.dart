import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/finance_enums.dart';

part 'budget_plan.freezed.dart';
part 'budget_plan.g.dart';

@freezed
class BudgetPlan with _$BudgetPlan {
  const factory BudgetPlan({
    required String id,
    required String userId,
    required String categoryName,
    required double limitAmount,
    required double spentAmount,
    @Default(BudgetPeriodType.monthly) BudgetPeriodType periodType,
    required String monthKey,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _BudgetPlan;

  const BudgetPlan._();

  double get progress =>
      limitAmount == 0 ? 0 : (spentAmount / limitAmount).clamp(0, 1);

  double get remainingAmount => limitAmount - spentAmount;

  BudgetHealth get health {
    if (spentAmount > limitAmount) {
      return BudgetHealth.overLimit;
    }
    if (progress >= 0.8) {
      return BudgetHealth.warning;
    }
    return BudgetHealth.onTrack;
  }

  factory BudgetPlan.fromJson(Map<String, dynamic> json) =>
      _$BudgetPlanFromJson(json);
}
