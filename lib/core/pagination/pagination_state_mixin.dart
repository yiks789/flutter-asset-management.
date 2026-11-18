import 'package:flutter/material.dart';

import 'page_delay.dart';
import 'pagination.dart';

/// Jarak ke dasar daftar yang memicu pemuatan halaman berikutnya.
const double kPaginationLoadThreshold = 200;

/// Logika pagination yang dipakai bersama Daftar Aset dan Riwayat Saya.
mixin PaginatedStateMixin<T extends StatefulWidget> on State<T> {
  late final ScrollController paginationController;

  int _page = 0;
  bool _isPageLoading = false;
  int _generation = 0;
  bool _postFrameScheduled = false;

  /// Total data pada filter aktif, bukan jumlah yang sudah dimuat.
  int get paginatedTotal;

  /// Jeda yang bisa dijadikan nol pada test.
  PageDelay get pageDelay;

  bool get isPageLoading => _isPageLoading;

  PageWindow get currentPageWindow => pageWindow(paginatedTotal, page: _page);

  int get visibleCount => currentPageWindow.visibleCount;

  bool get hasMorePages => currentPageWindow.hasMore;

  @override
  void initState() {
    super.initState();
    paginationController = ScrollController()
      ..addListener(_handlePaginationScroll);
  }

  @override
  void dispose() {
    paginationController.removeListener(_handlePaginationScroll);
    paginationController.dispose();
    super.dispose();
  }

  void _handlePaginationScroll() {
    if (!paginationController.hasClients || _isPageLoading || !hasMorePages) {
      return;
    }
    final ScrollPosition position = paginationController.position;
    if (position.pixels >=
        position.maxScrollExtent - kPaginationLoadThreshold) {
      loadNextPage();
    }
  }

  /// Cek setelah frame apakah konten terlalu pendek untuk di-scroll.
  void scheduleCheckForMore() {
    if (_postFrameScheduled) {
      return;
    }
    _postFrameScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postFrameScheduled = false;
      if (!mounted) {
        return;
      }
      final ScrollPosition? position = paginationController.hasClients
          ? paginationController.position
          : null;
      if (position == null || _isPageLoading || !hasMorePages) {
        return;
      }
      if (position.maxScrollExtent <= position.viewportDimension) {
        loadNextPage();
      }
    });
  }

  /// Ganti ke halaman 0. Tidak memanggil setState; panggil dari callback filter.
  void resetPaginationState() {
    _generation++;
    _page = 0;
    _isPageLoading = false;
  }

  /// Clamp halaman saat data menyusut. Tidak mengembalikan ke halaman 0.
  void clampPaginationState() {
    _generation++;
    final PageWindow clamped = clampPageWindow(
      paginatedTotal,
      currentPageWindow,
    );
    _page = clamped.page;
    _isPageLoading = false;
  }

  /// Reset lengkap termasuk scroll ke atas. Dipakai oleh helper test/widget.
  void resetPagination() {
    resetPaginationState();
    if (mounted) {
      setState(() {});
    }
    jumpPaginationToTop();
    scheduleCheckForMore();
  }

  void jumpPaginationToTop() {
    if (paginationController.hasClients) {
      paginationController.jumpTo(0);
    }
  }

  /// Muat 10 item berikutnya. Hasil lama diabaikan bila generation berubah.
  Future<void> loadNextPage() async {
    if (_isPageLoading || !hasMorePages) {
      return;
    }

    final int generation = ++_generation;
    final PageWindow next = nextPageWindow(paginatedTotal, currentPageWindow);
    setState(() => _isPageLoading = true);

    try {
      await pageDelay.wait(PageRequest(page: next.page));
      if (!mounted || generation != _generation) {
        return;
      }
      setState(() {
        _page = clampPageWindow(paginatedTotal, next).page;
        _isPageLoading = false;
      });
      scheduleCheckForMore();
    } catch (_) {
      if (!mounted || generation != _generation) {
        return;
      }
      setState(() => _isPageLoading = false);
    }
  }
}
