import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/finance_enums.dart';
import '../../domain/entities/transaction_record.dart';

part 'transaction_dto.freezed.dart';
part 'transaction_dto.g.dart';

@freezed
class TransactionDto with _$TransactionDto {
  const factory TransactionDto({
    required String id,
    required String userId,
    required TransactionType type,
    required String title,
    required double amount,
    required String categoryName,
    required String accountId,
    required String paymentMethod,
    String? note,
    required DateTime createdAt,
    required DateTime transactionDate,
    DateTime? updatedAt,
  }) = _TransactionDto;

  const TransactionDto._();

  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);

  factory TransactionDto.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return TransactionDto(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: TransactionType.values.byName(data['type'] as String? ?? 'expense'),
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      categoryName: data['categoryName'] as String? ?? '',
      accountId: data['accountId'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? '',
      note: data['note'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionDate:
          (data['transactionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  TransactionRecord toDomain() => TransactionRecord(
    id: id,
    userId: userId,
    type: type,
    title: title,
    amount: amount,
    categoryName: categoryName,
    accountId: accountId,
    paymentMethod: paymentMethod,
    note: note,
    createdAt: createdAt,
    transactionDate: transactionDate,
    updatedAt: updatedAt,
  );

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'type': type.name,
    'title': title,
    'amount': amount,
    'categoryName': categoryName,
    'accountId': accountId,
    'paymentMethod': paymentMethod,
    'note': note,
    'createdAt': Timestamp.fromDate(createdAt),
    'transactionDate': Timestamp.fromDate(transactionDate),
    'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
  };

  factory TransactionDto.fromDomain(TransactionRecord record) => TransactionDto(
    id: record.id,
    userId: record.userId,
    type: record.type,
    title: record.title,
    amount: record.amount,
    categoryName: record.categoryName,
    accountId: record.accountId,
    paymentMethod: record.paymentMethod,
    note: record.note,
    createdAt: record.createdAt,
    transactionDate: record.transactionDate,
    updatedAt: record.updatedAt,
  );
}
