// Helper filter generik yang dipakai bersama Riwayat dan Daftar Aset.

/// Kategori pilihan yang sudah tidak ada dibuang; null = "Semua".
String? normalizeSelectedCategory(List<String> categories, String? selected) {
  if (selected == null) {
    return null;
  }
  return categories.contains(selected) ? selected : null;
}

/// Hitung jumlah chip filter aktif untuk badge.
/// [multiCount] adalah jumlah pilihan dalam grup multi-select (bulan/status),
/// [hasSingle] true jika pilihan single-select (mis. kategori) bukan "Semua".
/// Pencarian sengaja tidak dihitung.
int filterBadgeCount({required int multiCount, required bool hasSingle}) {
  return multiCount + (hasSingle ? 1 : 0);
}
