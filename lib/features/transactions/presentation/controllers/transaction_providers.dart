import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums/finance_enums.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../data/repositories/firestore_transaction_repository.dart';
import '../../domain/entities/transaction_record.dart';
import '../../domain/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return FirestoreTransactionRepository(ref.watch(firestoreProvider));
});

final transactionsProvider = StreamProvider<List<TransactionRecord>>((
  ref,
) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield const [];
    return;
  }

  yield* ref.watch(transactionRepositoryProvider).watchTransactions(user.id);
});

class TransactionActionController extends StateNotifier<AsyncValue<void>> {
  TransactionActionController(this._repository) : super(const AsyncData(null));

  final TransactionRepository _repository;
  final _uuid = const Uuid();

  Future<void> save({
    required String userId,
    required String title,
    required double amount,
    required String categoryName,
    required String accountId,
    required String paymentMethod,
    required DateTime transactionDate,
    required TransactionType type,
    String? note,
    String? id,
    DateTime? createdAt,
  }) async {
    final now = DateTime.now();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.upsertTransaction(
        TransactionRecord(
          id: id ?? _uuid.v4(),
          userId: userId,
          type: type,
          title: title,
          amount: amount,
          categoryName: categoryName,
          accountId: accountId,
          paymentMethod: paymentMethod,
          note: note,
          createdAt: createdAt ?? now,
          transactionDate: transactionDate,
          updatedAt: now,
        ),
      );
    });
  }

  Future<void> delete({
    required String userId,
    required String transactionId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteTransaction(
        userId: userId,
        transactionId: transactionId,
      );
    });
  }
}

final transactionActionControllerProvider =
    StateNotifierProvider<TransactionActionController, AsyncValue<void>>((ref) {
      return TransactionActionController(
        ref.watch(transactionRepositoryProvider),
      );
    });
