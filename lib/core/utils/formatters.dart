import 'package:intl/intl.dart';

import '../constants/finance_defaults.dart';
import '../enums/finance_enums.dart';

final class AppFormatters {
  const AppFormatters._();

  static String currency(
    num value, {
    String currencyCode = FinanceDefaults.defaultCurrencyCode,
    int decimalDigits = 2,
  }) {
    final symbol = currencySymbol(currencyCode);
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(value);
  }

  static String currencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'INR':
        return 'Rs ';
      case 'USD':
        return r'$';
      case 'EUR':
        return 'EUR ';
      case 'GBP':
        return 'GBP ';
      default:
        return '${currencyCode.toUpperCase()} ';
    }
  }

  static String shortMonth(DateTime date) =>
      DateFormat('MMM yyyy').format(date);

  static String longDate(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  static String percentage(num value) => '${(value * 100).toStringAsFixed(0)}%';

  static String transactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }
}
