enum TransactionType {
  income,
  expense;

  bool get isIncome => this == TransactionType.income;
}

enum BudgetPeriodType { monthly }

enum GoalStatus { active, completed, overdue }

enum BudgetHealth { onTrack, warning, overLimit }
