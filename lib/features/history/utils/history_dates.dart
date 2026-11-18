import '../../../core/filter/filter_utils.dart' as filter_utils;
import '../../asset/models/loan_item.dart';
import '../models/month_key.dart';

export '../../../core/filter/filter_utils.dart' show normalizeSelectedCategory;

/// Fungsi murni untuk tanggal, tab, filter, dan ringkasan Riwayat (tanpa `intl`).
const List<String> kMonthAbbreviations = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

enum HistoryTab { borrowed, returned }

String monthLabel(MonthKey key) =>
    '${kMonthAbbreviations[key.month - 1]} ${key.year}';

/// Format: "17 Nov 2026, 09:10" (24 jam).
String formatDateTime(DateTime value) {
  final String day = value.day.toString().padLeft(2, '0');
  final String hour = value.hour.toString().padLeft(2, '0');
  final String minute = value.minute.toString().padLeft(2, '0');
  return '$day ${kMonthAbbreviations[value.month - 1]} ${value.year}, '
      '$hour:$minute';
}

/// Bulan yang punya data pada tab tertentu, terurut terbaru → terlama.
List<MonthKey> monthsForTab(List<LoanItem> loans, HistoryTab tab) {
  final Set<MonthKey> months = <MonthKey>{};

  for (final LoanItem loan in loans) {
    final DateTime? date = switch (tab) {
      HistoryTab.borrowed => loan.isActive ? loan.borrowDate : null,
      HistoryTab.returned => loan.returnDate,
    };
    if (date != null) {
      months.add(MonthKey.fromDateTime(date));
    }
  }

  final List<MonthKey> result = months.toList();
  result.sort();
  return result;
}

/// Kategori unik yang dipakai pinjaman pada tab tertentu, urut abjad.
/// Kategori diambil dari [categoryOf], bukan disimpan duplikat di `LoanItem`.
List<String> categoriesForTab(
  List<LoanItem> loans,
  HistoryTab tab,
  String Function(LoanItem) categoryOf,
) {
  final Set<String> categories = <String>{};

  for (final LoanItem loan in loans) {
    final bool matchesTab = switch (tab) {
      HistoryTab.borrowed => loan.isActive,
      HistoryTab.returned => !loan.isActive,
    };
    if (!matchesTab) {
      continue;
    }
    final String category = categoryOf(loan).trim();
    if (category.isNotEmpty) {
      categories.add(category);
    }
  }

  final List<String> result = categories.toList();
  result.sort();
  return result;
}

/// Satu fungsi penyaring Riwayat: AND antar grup, OR di dalam grup bulan.
/// [months] kosong berarti semua bulan; [category] null berarti "Semua".
/// [query] di-trim dan tidak peka huruf besar/kecil untuk nama maupun kode.
List<LoanItem> loansForFilters(
  List<LoanItem> loans,
  HistoryTab tab,
  Set<MonthKey> months,
  String? category,
  String query,
  String Function(LoanItem) categoryOf,
) {
  final String keyword = query.trim().toLowerCase();
  final String? selectedCategory = category?.trim();
  final bool hasCategory =
      selectedCategory != null && selectedCategory.isNotEmpty;

  return loans
      .where((LoanItem loan) {
        final bool matchesTab = switch (tab) {
          HistoryTab.borrowed => loan.isActive,
          HistoryTab.returned => !loan.isActive,
        };
        if (!matchesTab) {
          return false;
        }

        if (months.isNotEmpty) {
          final DateTime date = switch (tab) {
            HistoryTab.borrowed => loan.borrowDate,
            HistoryTab.returned => loan.returnDate!,
          };
          if (!months.contains(MonthKey.fromDateTime(date))) {
            return false;
          }
        }

        if (hasCategory && categoryOf(loan).trim() != selectedCategory) {
          return false;
        }

        if (keyword.isNotEmpty) {
          final bool matchesQuery =
              loan.assetName.toLowerCase().contains(keyword) ||
              loan.assetCode.toLowerCase().contains(keyword);
          if (!matchesQuery) {
            return false;
          }
        }

        return true;
      })
      .toList(growable: false);
}

/// Bulan pilihan yang sudah tidak punya data dibuang. Kosong = semua bulan.
Set<MonthKey> normalizeSelectedMonths(
  List<MonthKey> months,
  Set<MonthKey> selected,
) {
  return selected.where((MonthKey month) => months.contains(month)).toSet();
}

/// Kategori pilihan yang sudah tidak ada dibuang; null = "Semua".
String? normalizeSelectedCategory(List<String> categories, String? selected) {
  return filter_utils.normalizeSelectedCategory(categories, selected);
}

/// Jumlah chip filter aktif untuk badge. Pencarian sengaja tidak dihitung.
int activeFilterCount(Set<MonthKey> months, String? category) {
  final bool hasCategory = category != null && category.trim().isNotEmpty;
  return months.length + (hasCategory ? 1 : 0);
}

/// Satu-satunya baris meta kartu: kode + tanggal, tanpa duplikasi tanggal.
String loanSubtitle(LoanItem loan) {
  if (loan.isActive) {
    return '${loan.assetCode} · Sejak ${formatDateTime(loan.borrowDate)}';
  }
  return '${loan.assetCode} · Dikembalikan ${formatDateTime(loan.returnDate!)}';
}

String summaryText(HistoryTab tab, int count) {
  final String verb = switch (tab) {
    HistoryTab.borrowed => 'dipinjam',
    HistoryTab.returned => 'dikembalikan',
  };
  return '$count aset $verb';
}
