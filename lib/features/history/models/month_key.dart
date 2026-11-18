/// Kunci bulan (tanpa hari/jam) untuk filter riwayat.
class MonthKey implements Comparable<MonthKey> {
  const MonthKey(this.year, this.month);

  final int year;
  final int month;

  factory MonthKey.fromDateTime(DateTime date) =>
      MonthKey(date.year, date.month);

  /// Nilai negatif berarti [this] lebih baru dari [other].
  @override
  int compareTo(MonthKey other) {
    if (year != other.year) {
      return other.year.compareTo(year);
    }
    return other.month.compareTo(month);
  }

  @override
  bool operator ==(Object other) =>
      other is MonthKey && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => '$year-$month';
}
