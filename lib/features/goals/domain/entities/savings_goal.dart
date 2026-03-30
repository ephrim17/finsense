import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/finance_enums.dart';

part 'savings_goal.freezed.dart';
part 'savings_goal.g.dart';

@freezed
class SavingsGoal with _$SavingsGoal {
  const factory SavingsGoal({
    required String id,
    required String userId,
    required String title,
    required double targetAmount,
    required double currentAmount,
    required String icon,
    required String color,
    DateTime? deadline,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _SavingsGoal;

  const SavingsGoal._();

  double get progress =>
      targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1);

  GoalStatus get status {
    if (currentAmount >= targetAmount) {
      return GoalStatus.completed;
    }
    if (deadline != null && deadline!.isBefore(DateTime.now())) {
      return GoalStatus.overdue;
    }
    return GoalStatus.active;
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalFromJson(json);
}
