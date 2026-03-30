import '../enums/finance_enums.dart';

final class FinanceDefaults {
  const FinanceDefaults._();

  static const defaultCurrencyCode = 'INR';

  static const expenseCategories = [
    'Groceries',
    'Food & Dining',
    'Transport',
    'Shopping',
    'Bills & Utilities',
    'Rent',
    'Health',
    'Entertainment',
    'Travel',
    'Education',
    'Family',
    'Other Expense',
  ];

  static const incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Rental Income',
    'Bonus',
    'Gift',
    'Refund',
    'Other Income',
  ];

  static List<String> categoriesFor(TransactionType type) {
    return switch (type) {
      TransactionType.expense => expenseCategories,
      TransactionType.income => incomeCategories,
    };
  }
}
