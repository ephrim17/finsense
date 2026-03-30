class ReportSnapshot {
  const ReportSnapshot({
    required this.totalIncome,
    required this.totalExpenses,
    required this.expenseCategorySpend,
    required this.incomeCategorySpend,
  });

  final double totalIncome;
  final double totalExpenses;
  final Map<String, double> expenseCategorySpend;
  final Map<String, double> incomeCategorySpend;
}
