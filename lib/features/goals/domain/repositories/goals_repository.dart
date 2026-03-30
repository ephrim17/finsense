import '../entities/savings_goal.dart';

abstract class GoalsRepository {
  Stream<List<SavingsGoal>> watchGoals(String userId);
  Future<void> upsertGoal(SavingsGoal goal);
  Future<void> deleteGoal({required String userId, required String goalId});
}
