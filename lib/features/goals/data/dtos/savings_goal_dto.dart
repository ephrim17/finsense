import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/savings_goal.dart';

part 'savings_goal_dto.freezed.dart';
part 'savings_goal_dto.g.dart';

@freezed
class SavingsGoalDto with _$SavingsGoalDto {
  const factory SavingsGoalDto({
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
  }) = _SavingsGoalDto;

  const SavingsGoalDto._();

  factory SavingsGoalDto.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalDtoFromJson(json);

  factory SavingsGoalDto.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return SavingsGoalDto(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0,
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0,
      icon: data['icon'] as String? ?? 'target',
      color: data['color'] as String? ?? '#8B5CF6',
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  SavingsGoal toDomain() => SavingsGoal(
    id: id,
    userId: userId,
    title: title,
    targetAmount: targetAmount,
    currentAmount: currentAmount,
    icon: icon,
    color: color,
    deadline: deadline,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory SavingsGoalDto.fromDomain(SavingsGoal goal) => SavingsGoalDto(
    id: goal.id,
    userId: goal.userId,
    title: goal.title,
    targetAmount: goal.targetAmount,
    currentAmount: goal.currentAmount,
    icon: goal.icon,
    color: goal.color,
    deadline: goal.deadline,
    createdAt: goal.createdAt,
    updatedAt: goal.updatedAt,
  );

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'title': title,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'icon': icon,
    'color': color,
    'deadline': deadline == null ? null : Timestamp.fromDate(deadline!),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
  };
}
