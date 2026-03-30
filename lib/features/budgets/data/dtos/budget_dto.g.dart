// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetDtoImpl _$$BudgetDtoImplFromJson(Map<String, dynamic> json) =>
    _$BudgetDtoImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryName: json['categoryName'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
      periodType:
          $enumDecodeNullable(_$BudgetPeriodTypeEnumMap, json['periodType']) ??
          BudgetPeriodType.monthly,
      monthKey: json['monthKey'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BudgetDtoImplToJson(_$BudgetDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'categoryName': instance.categoryName,
      'limitAmount': instance.limitAmount,
      'spentAmount': instance.spentAmount,
      'periodType': _$BudgetPeriodTypeEnumMap[instance.periodType]!,
      'monthKey': instance.monthKey,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$BudgetPeriodTypeEnumMap = {BudgetPeriodType.monthly: 'monthly'};
