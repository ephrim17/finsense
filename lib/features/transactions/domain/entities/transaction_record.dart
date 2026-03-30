import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/finance_enums.dart';

part 'transaction_record.freezed.dart';
part 'transaction_record.g.dart';

@freezed
class TransactionRecord with _$TransactionRecord {
  const factory TransactionRecord({
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
  }) = _TransactionRecord;

  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      _$TransactionRecordFromJson(json);
}
