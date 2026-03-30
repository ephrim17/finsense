extension IterableNumX on Iterable<num> {
  double get sum => fold<double>(0, (sum, item) => sum + item.toDouble());
}
