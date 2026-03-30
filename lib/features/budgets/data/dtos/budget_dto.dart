import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/finance_enums.dart';
import '../../domain/entities/budget_plan.dart';

part 'budget_dto.freezed.dart';
part 'budget_dto.g.dart';

@freezed
class BudgetDto with _$BudgetDto {
  const factory BudgetDto({
    required String id,
    required String userId,
    required String categoryName,
    required double limitAmount,
    required double spentAmount,
    @Default(BudgetPeriodType.monthly) BudgetPeriodType periodType,
    required String monthKey,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _BudgetDto;

  const BudgetDto._();

  factory BudgetDto.fromJson(Map<String, dynamic> json) =>
      _$BudgetDtoFromJson(json);

  factory BudgetDto.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return BudgetDto(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      limitAmount: (data['limitAmount'] as num?)?.toDouble() ?? 0,
      spentAmount: (data['spentAmount'] as num?)?.toDouble() ?? 0,
      periodType: BudgetPeriodType.values.byName(
        data['periodType'] as String? ?? 'monthly',
      ),
      monthKey: data['monthKey'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  BudgetPlan toDomain() => BudgetPlan(
    id: id,
    userId: userId,
    categoryName: categoryName,
    limitAmount: limitAmount,
    spentAmount: spentAmount,
    periodType: periodType,
    monthKey: monthKey,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory BudgetDto.fromDomain(BudgetPlan budget) => BudgetDto(
    id: budget.id,
    userId: budget.userId,
    categoryName: budget.categoryName,
    limitAmount: budget.limitAmount,
    spentAmount: budget.spentAmount,
    periodType: budget.periodType,
    monthKey: budget.monthKey,
    createdAt: budget.createdAt,
    updatedAt: budget.updatedAt,
  );

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'categoryName': categoryName,
    'limitAmount': limitAmount,
    'spentAmount': spentAmount,
    'periodType': periodType.name,
    'monthKey': monthKey,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
  };
}
