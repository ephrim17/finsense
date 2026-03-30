final class FirestorePaths {
  const FirestorePaths._();

  static String user(String uid) => 'users/$uid';
  static String transactions(String uid) => 'users/$uid/transactions';
  static String transaction(String uid, String transactionId) =>
      'users/$uid/transactions/$transactionId';
  static String budgets(String uid) => 'users/$uid/budgets';
  static String budget(String uid, String budgetId) =>
      'users/$uid/budgets/$budgetId';
  static String goals(String uid) => 'users/$uid/goals';
  static String goal(String uid, String goalId) => 'users/$uid/goals/$goalId';
  static String accounts(String uid) => 'users/$uid/accounts';
  static String settings(String uid) => 'users/$uid/settings/preferences';
}
