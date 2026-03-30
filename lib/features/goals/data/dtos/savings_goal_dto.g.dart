// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavingsGoalDtoImpl _$$SavingsGoalDtoImplFromJson(Map<String, dynamic> json) =>
    _$SavingsGoalDtoImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      icon: json['icon'] as String,
      color: json['color'] as String,
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SavingsGoalDtoImplToJson(
  _$SavingsGoalDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'targetAmount': instance.targetAmount,
  'currentAmount': instance.currentAmount,
  'icon': instance.icon,
  'color': instance.color,
  'deadline': instance.deadline?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
