import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/extensions/date_time_x.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../data/repositories/firestore_budget_repository.dart';
import '../../domain/entities/budget_plan.dart';
import '../../domain/repositories/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return FirestoreBudgetRepository(ref.watch(firestoreProvider));
});

final budgetsProvider = StreamProvider<List<BudgetPlan>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield const [];
    return;
  }

  yield* ref.watch(budgetRepositoryProvider).watchBudgets(user.id);
});

class BudgetActionController extends StateNotifier<AsyncValue<void>> {
  BudgetActionController(this._repository) : super(const AsyncData(null));

  final BudgetRepository _repository;
  final _uuid = const Uuid();

  Future<void> save({
    required String userId,
    required String categoryName,
    required double limitAmount,
    double spentAmount = 0,
    String? id,
  }) async {
    final now = DateTime.now();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.upsertBudget(
        BudgetPlan(
          id: id ?? _uuid.v4(),
          userId: userId,
          categoryName: categoryName,
          limitAmount: limitAmount,
          spentAmount: spentAmount,
          monthKey: now.monthKey,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });
  }

  Future<void> delete({
    required String userId,
    required String budgetId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteBudget(userId: userId, budgetId: budgetId);
    });
  }
}

final budgetActionControllerProvider =
    StateNotifierProvider<BudgetActionController, AsyncValue<void>>((ref) {
      return BudgetActionController(ref.watch(budgetRepositoryProvider));
    });
