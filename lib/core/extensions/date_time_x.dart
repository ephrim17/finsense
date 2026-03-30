extension DateTimeX on DateTime {
  String get monthKey {
    final month = this.month.toString().padLeft(2, '0');
    return '${year}_$month';
  }

  DateTime get startOfMonth => DateTime(year, month);

  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);
}
