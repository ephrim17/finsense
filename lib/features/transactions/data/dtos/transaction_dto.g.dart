// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionDtoImpl _$$TransactionDtoImplFromJson(Map<String, dynamic> json) =>
    _$TransactionDtoImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryName: json['categoryName'] as String,
      accountId: json['accountId'] as String,
      paymentMethod: json['paymentMethod'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TransactionDtoImplToJson(
  _$TransactionDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'title': instance.title,
  'amount': instance.amount,
  'categoryName': instance.categoryName,
  'accountId': instance.accountId,
  'paymentMethod': instance.paymentMethod,
  'note': instance.note,
  'createdAt': instance.createdAt.toIso8601String(),
  'transactionDate': instance.transactionDate.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
};
