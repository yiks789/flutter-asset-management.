import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/features/asset/data/dummy_assets.dart';
import 'package:flutter_application_1/features/asset/data/dummy_loans.dart';
import 'package:flutter_application_1/features/asset/models/asset_item.dart';
import 'package:flutter_application_1/features/asset/models/loan_item.dart';
import 'package:flutter_application_1/features/history/models/month_key.dart';
import 'package:flutter_application_1/features/history/utils/history_dates.dart';

String _categoryOf(LoanItem loan) {
  for (final AssetItem asset in dummyAssets) {
    if (asset.code == loan.assetCode) {
      return asset.category;
    }
  }
  return '';
}

void main() {
  group('MonthKey', () {
    test('mengurutkan bulan terbaru lebih dulu', () {
      final List<MonthKey> months = <MonthKey>[
        const MonthKey(2025, 5),
        const MonthKey(2026, 11),
        const MonthKey(2026, 10),
        const MonthKey(2025, 12),
      ]..sort();

      expect(months, const <MonthKey>[
        MonthKey(2026, 11),
        MonthKey(2026, 10),
        MonthKey(2025, 12),
        MonthKey(2025, 5),
      ]);
    });

    test('equality dan hashCode berdasarkan year + month', () {
      expect(const MonthKey(2026, 11), const MonthKey(2026, 11));
      expect(
        const MonthKey(2026, 11).hashCode,
        const MonthKey(2026, 11).hashCode,
      );
      expect(const MonthKey(2026, 11) == const MonthKey(2026, 10), isFalse);
    });
  });

  group('monthsForTab', () {
    test('chip Dipinjam hanya memakai borrowDate pinjaman aktif', () {
      expect(monthsForTab(dummyLoans, HistoryTab.borrowed), const <MonthKey>[
        MonthKey(2026, 11),
        MonthKey(2026, 10),
        MonthKey(2026, 9),
        MonthKey(2026, 8),
        MonthKey(2026, 7),
      ]);
    });

    test('chip Dikembalikan hanya memakai returnDate', () {
      expect(monthsForTab(dummyLoans, HistoryTab.returned), const <MonthKey>[
        MonthKey(2026, 10),
        MonthKey(2026, 7),
        MonthKey(2026, 6),
        MonthKey(2026, 4),
        MonthKey(2026, 2),
        MonthKey(2025, 12),
        MonthKey(2025, 11),
        MonthKey(2025, 9),
        MonthKey(2025, 5),
      ]);
    });

    test('mengabaikan pinjaman tanpa returnDate pada tab Dikembalikan', () {
      final List<MonthKey> months = monthsForTab(<LoanItem>[
        LoanItem(
          assetCode: 'AST-099',
          assetName: 'Aktif',
          borrowDate: DateTime(2026, 9, 1),
        ),
      ], HistoryTab.returned);

      expect(months, isEmpty);
    });

    test('Sep 2026 sengaja tidak ada pada tab Dikembalikan', () {
      expect(
        monthsForTab(dummyLoans, HistoryTab.returned),
        isNot(contains(const MonthKey(2026, 9))),
      );
    });
  });

  group('categoriesForTab', () {
    test('Dipinjam memuat Laptop, Smartphone, dan Peralatan Kantor', () {
      final List<String> categories = categoriesForTab(
        dummyLoans,
        HistoryTab.borrowed,
        _categoryOf,
      );

      expect(categories, <String>[
        'Aksesoris',
        'Jaringan',
        'Laptop',
        'Peralatan Kantor',
        'Smartphone',
      ]);
    });

    test('Dikembalikan diurutkan abjad', () {
      final List<String> categories = categoriesForTab(
        dummyLoans,
        HistoryTab.returned,
        _categoryOf,
      );

      expect(categories, <String>[
        'Aksesoris',
        'Laptop',
        'Peralatan Kantor',
        'Smartphone',
      ]);
    });

    test('kategori kosong diabaikan', () {
      expect(
        categoriesForTab(dummyLoans, HistoryTab.borrowed, (_) => ''),
        isEmpty,
      );
    });
  });

  group('loansForFilters', () {
    test('satu pinjaman tidak muncul di dua tab sekaligus', () {
      final List<LoanItem> active = loansForFilters(
        dummyLoans,
        HistoryTab.borrowed,
        const <MonthKey>{},
        null,
        '',
        _categoryOf,
      );
      final List<LoanItem> returned = loansForFilters(
        dummyLoans,
        HistoryTab.returned,
        const <MonthKey>{},
        null,
        '',
        _categoryOf,
      );

      expect(active, hasLength(12));
      expect(returned, hasLength(27));
      for (final LoanItem loan in active) {
        expect(returned.contains(loan), isFalse);
      }
    });

    test('bulan kosong berarti semua bulan; bulan jamak bersifat OR', () {
      final Set<MonthKey> months = <MonthKey>{
        const MonthKey(2026, 11),
        const MonthKey(2026, 10),
      };
      final List<LoanItem> loans = loansForFilters(
        dummyLoans,
        HistoryTab.borrowed,
        months,
        null,
        '',
        _categoryOf,
      );

      expect(loans, hasLength(5));
      expect(loans.map((LoanItem loan) => loan.assetCode), contains('AST-003'));
    });

    test('AND antar bulan, kategori, dan pencarian; Dell AST-003 lolos', () {
      final List<LoanItem> loans = loansForFilters(
        dummyLoans,
        HistoryTab.borrowed,
        <MonthKey>{const MonthKey(2026, 11), const MonthKey(2026, 10)},
        'Laptop',
        '  DELL  ',
        _categoryOf,
      );

      expect(loans, hasLength(1));
      expect(loans.single.assetCode, 'AST-003');
    });

    test('pencarian memakai nama atau kode, di-trim dan abaikan huruf', () {
      expect(
        loansForFilters(
          dummyLoans,
          HistoryTab.borrowed,
          const <MonthKey>{},
          null,
          '  iphone  ',
          _categoryOf,
        ).map((LoanItem loan) => loan.assetCode),
        <String>['AST-010'],
      );
      expect(
        loansForFilters(
          dummyLoans,
          HistoryTab.borrowed,
          const <MonthKey>{},
          null,
          'ast-018',
          _categoryOf,
        ).map((LoanItem loan) => loan.assetCode),
        <String>['AST-018'],
      );
    });

    test('kategori dan bulan memakai returnDate pada tab Dikembalikan', () {
      final List<LoanItem> loans = loansForFilters(
        dummyLoans,
        HistoryTab.returned,
        <MonthKey>{const MonthKey(2026, 10)},
        'Peralatan Kantor',
        '',
        _categoryOf,
      );

      expect(loans, hasLength(1));
      expect(loans.single.assetCode, 'AST-005');
    });
  });

  group('normalisasi pilihan', () {
    const List<MonthKey> months = <MonthKey>[
      MonthKey(2026, 11),
      MonthKey(2026, 10),
    ];

    test('bulan yang hilang dibuang, yang ada tetap dipakai', () {
      expect(normalizeSelectedMonths(months, const <MonthKey>{}), isEmpty);
      expect(
        normalizeSelectedMonths(months, <MonthKey>{
          const MonthKey(2026, 10),
          const MonthKey(2026, 9),
        }),
        <MonthKey>{const MonthKey(2026, 10)},
      );
    });

    test('kategori yang hilang jadi null (= Semua)', () {
      const List<String> categories = <String>['Laptop', 'Smartphone'];
      expect(normalizeSelectedCategory(categories, null), isNull);
      expect(normalizeSelectedCategory(categories, 'Laptop'), 'Laptop');
      expect(normalizeSelectedCategory(categories, 'Tablet'), isNull);
    });
  });

  test('activeFilterCount menghitung bulan + kategori, bukan pencarian', () {
    expect(activeFilterCount(const <MonthKey>{}, null), 0);
    expect(activeFilterCount(<MonthKey>{const MonthKey(2026, 11)}, null), 1);
    expect(
      activeFilterCount(<MonthKey>{
        const MonthKey(2026, 11),
        const MonthKey(2026, 10),
      }, 'Laptop'),
      3,
    );
  });

  test('format tanggal memakai singkatan Indonesia dan 24 jam', () {
    expect(formatDateTime(DateTime(2026, 11, 17, 9, 10)), '17 Nov 2026, 09:10');
    expect(monthLabel(const MonthKey(2025, 5)), 'Mei 2025');
  });

  test('loanSubtitle menggabungkan kode dan satu tanggal', () {
    expect(
      loanSubtitle(dummyLoans.first),
      'AST-003 · Sejak 17 Nov 2026, 09:10',
    );
    expect(
      loanSubtitle(
        LoanItem(
          assetCode: 'AST-003',
          assetName: 'Dell Latitude 5440',
          borrowDate: DateTime(2026, 11, 1, 8, 0),
          returnDate: DateTime(2026, 11, 17, 14, 20),
        ),
      ),
      'AST-003 · Dikembalikan 17 Nov 2026, 14:20',
    );
  });

  test('summaryText hanya memakai total terfilter tanpa akhiran bulan', () {
    expect(summaryText(HistoryTab.borrowed, 12), '12 aset dipinjam');
    expect(summaryText(HistoryTab.returned, 27), '27 aset dikembalikan');
  });
}
