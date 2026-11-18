/// Satu riwayat pinjaman aset. [returnDate] null berarti masih dipinjam.
class LoanItem {
  const LoanItem({
    required this.assetCode,
    required this.assetName,
    required this.borrowDate,
    this.returnDate,
  });

  final String assetCode;
  final String assetName;
  final DateTime borrowDate;
  final DateTime? returnDate;

  bool get isActive => returnDate == null;
}
