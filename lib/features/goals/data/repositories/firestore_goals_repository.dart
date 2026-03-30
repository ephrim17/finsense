import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/goals_repository.dart';
import '../dtos/savings_goal_dto.dart';

class FirestoreGoalsRepository implements GoalsRepository {
  FirestoreGoalsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<SavingsGoal>> watchGoals(String userId) {
    return _firestore
        .collection(FirestorePaths.goals(userId))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(SavingsGoalDto.fromFirestore)
              .map((dto) => dto.toDomain())
              .toList(),
        );
  }

  @override
  Future<void> upsertGoal(SavingsGoal goal) {
    return _firestore
        .doc(FirestorePaths.goal(goal.userId, goal.id))
        .set(
          SavingsGoalDto.fromDomain(goal).toFirestore(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteGoal({required String userId, required String goalId}) {
    return _firestore.doc(FirestorePaths.goal(userId, goalId)).delete();
  }
}
