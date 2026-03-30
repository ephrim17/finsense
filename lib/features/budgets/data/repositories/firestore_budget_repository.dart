import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../domain/entities/budget_plan.dart';
import '../../domain/repositories/budget_repository.dart';
import '../dtos/budget_dto.dart';

class FirestoreBudgetRepository implements BudgetRepository {
  FirestoreBudgetRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<BudgetPlan>> watchBudgets(String userId) {
    return _firestore
        .collection(FirestorePaths.budgets(userId))
        .orderBy('monthKey', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(BudgetDto.fromFirestore)
              .map((dto) => dto.toDomain())
              .toList(),
        );
  }

  @override
  Future<void> upsertBudget(BudgetPlan budget) {
    return _firestore
        .doc(FirestorePaths.budget(budget.userId, budget.id))
        .set(
          BudgetDto.fromDomain(budget).toFirestore(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteBudget({
    required String userId,
    required String budgetId,
  }) {
    return _firestore.doc(FirestorePaths.budget(userId, budgetId)).delete();
  }
}
