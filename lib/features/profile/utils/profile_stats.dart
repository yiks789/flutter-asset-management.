import '../../asset/models/loan_item.dart';

/// Statistik profil dihitung dari data pinjaman, bukan hardcode.
({int borrowed, int returned}) profileStats(List<LoanItem> loans) {
  int borrowed = 0;
  int returned = 0;

  for (final LoanItem loan in loans) {
    if (loan.isActive) {
      borrowed++;
    } else {
      returned++;
    }
  }

  return (borrowed: borrowed, returned: returned);
}
