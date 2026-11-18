import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/core/pagination/page_delay.dart';
import 'package:flutter_application_1/core/pagination/pagination.dart';

void main() {
  group('pageWindow', () {
    test('halaman pertama menampilkan 10 dari 25 item', () {
      final PageWindow window = pageWindow(25);
      expect(window.page, 0);
      expect(window.visibleCount, 10);
      expect(window.hasMore, isTrue);
    });

    test('halaman berikutnya menambah 10 item', () {
      expect(pageWindow(25, page: 1).visibleCount, 20);
      expect(pageWindow(25, page: 1).hasMore, isTrue);
    });

    test('halaman terakhir menampilkan semua item dan tidak punya next', () {
      final PageWindow window = pageWindow(25, page: 2);
      expect(window.visibleCount, 25);
      expect(window.hasMore, isFalse);
      expect(nextPageWindow(25, window).visibleCount, 25);
    });

    test('total lebih kecil dari pageSize tidak memunculkan loader', () {
      final PageWindow window = pageWindow(4);
      expect(window.visibleCount, 4);
      expect(window.hasMore, isFalse);
      expect(pageWindow(0).visibleCount, 0);
    });

    test('page_size bisa diset lewat PageRequest', () {
      expect(pageWindow(25, page: 1, pageSize: 5).visibleCount, 10);
      expect(const PageRequest(page: 1).pageSize, kPaginationPageSize);
    });
  });

  group('clampPageWindow', () {
    test('data menyusut tidak mengembalikan ke halaman 0', () {
      final PageWindow current = pageWindow(25, page: 2);
      final PageWindow clamped = clampPageWindow(12, current);
      expect(clamped.page, 1);
      expect(clamped.visibleCount, 12);
      expect(clamped.hasMore, isFalse);
    });

    test('data kosong menghasilkan nol', () {
      final PageWindow clamped = clampPageWindow(0, pageWindow(25, page: 2));
      expect(clamped.page, 0);
      expect(clamped.visibleCount, 0);
      expect(clamped.hasMore, isFalse);
    });
  });

  test('TimedPageDelay nol langsung selesai', () async {
    const TimedPageDelay delay = TimedPageDelay(Duration.zero);
    await delay.wait(const PageRequest(page: 1));
    expect(delay.duration, Duration.zero);
  });
}
