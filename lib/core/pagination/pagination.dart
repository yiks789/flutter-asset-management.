import 'dart:math' as math;

/// Ukuran satu halaman. Dipakai Daftar Aset dan Riwayat Saya.
const int kPaginationPageSize = 10;

/// Jeda simulasi agar loader terlihat saat memuat halaman berikutnya.
const Duration kPageLoadDelay = Duration(milliseconds: 400);

/// Permintaan satu halaman. [page] dimensionless mulai dari 0.
class PageRequest {
  const PageRequest({required this.page, this.pageSize = kPaginationPageSize});

  final int page;
  final int pageSize;
}

/// Hasil murni dari perhitungan pagination.
class PageWindow {
  const PageWindow({
    required this.page,
    required this.visibleCount,
    required this.hasMore,
  });

  final int page;
  final int visibleCount;
  final bool hasMore;
}

/// Hitung jumlah item yang tampil untuk [page] dan total [total].
PageWindow pageWindow(
  int total, {
  int page = 0,
  int pageSize = kPaginationPageSize,
}) {
  if (total <= 0 || pageSize <= 0) {
    return const PageWindow(page: 0, visibleCount: 0, hasMore: false);
  }

  final int safePage = page < 0 ? 0 : page;
  final int visibleCount = math.min((safePage + 1) * pageSize, total);
  return PageWindow(
    page: safePage,
    visibleCount: visibleCount,
    hasMore: visibleCount < total,
  );
}

/// Halaman berikutnya setelah [current].
PageWindow nextPageWindow(
  int total,
  PageWindow current, {
  int pageSize = kPaginationPageSize,
}) {
  return pageWindow(total, page: current.page + 1, pageSize: pageSize);
}

/// Sesuaikan halaman saat total data menyusut, tanpa mengembalikan ke halaman 0.
PageWindow clampPageWindow(
  int total,
  PageWindow current, {
  int pageSize = kPaginationPageSize,
}) {
  if (total <= 0 || pageSize <= 0) {
    return const PageWindow(page: 0, visibleCount: 0, hasMore: false);
  }

  final int maxPage = (total - 1) ~/ pageSize;
  final int safePage = current.page < 0
      ? 0
      : (current.page > maxPage ? maxPage : current.page);
  return pageWindow(total, page: safePage, pageSize: pageSize);
}
