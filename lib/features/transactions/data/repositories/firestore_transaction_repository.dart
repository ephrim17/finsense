import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../domain/entities/transaction_record.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../dtos/transaction_dto.dart';

class FirestoreTransactionRepository implements TransactionRepository {
  FirestoreTransactionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<TransactionRecord>> watchTransactions(String userId) {
    return _firestore
        .collection(FirestorePaths.transactions(userId))
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(TransactionDto.fromFirestore)
              .map((dto) => dto.toDomain())
              .toList(),
        );
  }

  @override
  Future<void> upsertTransaction(TransactionRecord transaction) {
    return _firestore
        .doc(FirestorePaths.transaction(transaction.userId, transaction.id))
        .set(
          TransactionDto.fromDomain(transaction).toFirestore(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  }) {
    return _firestore
        .doc(FirestorePaths.transaction(userId, transactionId))
        .delete();
  }
}
