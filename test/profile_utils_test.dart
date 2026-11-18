import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/features/asset/models/loan_item.dart';
import 'package:flutter_application_1/features/profile/utils/profile_initials.dart';
import 'package:flutter_application_1/features/profile/utils/profile_stats.dart';

void main() {
  group('profileInitials', () {
    test('mengambil huruf pertama dua kata pertama', () {
      expect(profileInitials('Rina Putri'), 'RP');
      expect(profileInitials('  rina   putri  '), 'RP');
    });

    test('nama satu kata dan kosong tetap aman', () {
      expect(profileInitials('Rina'), 'R');
      expect(profileInitials('   '), '');
    });
  });

  group('profileStats', () {
    test('menghitung pinjaman aktif dan selesai dari data', () {
      final List<LoanItem> loans = <LoanItem>[
        LoanItem(
          assetCode: 'AST-001',
          assetName: 'A',
          borrowDate: DateTime(2026, 11, 1),
        ),
        LoanItem(
          assetCode: 'AST-002',
          assetName: 'B',
          borrowDate: DateTime(2026, 10, 1),
        ),
        LoanItem(
          assetCode: 'AST-003',
          assetName: 'C',
          borrowDate: DateTime(2026, 9, 1),
          returnDate: DateTime(2026, 9, 5),
        ),
      ];

      expect(profileStats(loans), (borrowed: 2, returned: 1));
    });

    test('list kosong menghasilkan nol', () {
      expect(profileStats(const <LoanItem>[]), (borrowed: 0, returned: 0));
    });
  });
}
