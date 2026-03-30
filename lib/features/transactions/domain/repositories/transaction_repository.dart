import '../entities/transaction_record.dart';

abstract class TransactionRepository {
  Stream<List<TransactionRecord>> watchTransactions(String userId);
  Future<void> upsertTransaction(TransactionRecord transaction);
  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  });
}
