import '../entities/budget_plan.dart';

abstract class BudgetRepository {
  Stream<List<BudgetPlan>> watchBudgets(String userId);
  Future<void> upsertBudget(BudgetPlan budget);
  Future<void> deleteBudget({required String userId, required String budgetId});
}
