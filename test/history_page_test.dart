import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application_1/core/navigation/app_shell.dart';
import 'package:flutter_application_1/core/pagination/page_delay.dart';
import 'package:flutter_application_1/features/asset/data/asset_repository.dart';
import 'package:flutter_application_1/features/asset/data/asset_repository_scope.dart';
import 'package:flutter_application_1/features/asset/data/asset_return_service.dart';
import 'package:flutter_application_1/features/asset/models/asset_status.dart';
import 'package:flutter_application_1/core/filter/widgets/two_row_chip_scroll.dart';
import 'package:flutter_application_1/features/history/widgets/active_filter_chips.dart';
import 'package:flutter_application_1/features/history/widgets/filter_button.dart';
import 'package:flutter_application_1/features/history/widgets/history_filter_sheet.dart';
import 'package:flutter_application_1/features/history/widgets/history_search_field.dart';
import 'package:flutter_application_1/features/history/widgets/loan_card.dart';
import 'package:flutter_application_1/features/history/widgets/selectable_chip.dart';

import 'helpers/auth_helpers.dart';
import 'helpers/fake_clock.dart';
import 'helpers/pagination_helpers.dart';

Widget _buildApp(
  AssetRepository repository, {
  AssetReturnService? returnService,
  PageDelay pageDelay = zeroPageDelay,
  Duration searchDebounce = zeroSearchDebounce,
}) {
  return signedInAuthScope(
    child: AssetRepositoryScope(
      repository: repository,
      clock: FakeClock(),
      child: MaterialApp(
        home: AppShell(
          historyReturnService: returnService,
          historyClock: FakeClock(),
          pageDelay: pageDelay,
          historySearchDebounce: searchDebounce,
        ),
      ),
    ),
  );
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _openHistory(WidgetTester tester) async {
  await tester.tap(find.text('Riwayat'));
  await tester.pumpAndSettle();
}

Finder _historyScrollView(WidgetTester tester) {
  return find.ancestor(
    of: find.text('Riwayat Saya'),
    matching: find.byType(SingleChildScrollView),
  );
}

Future<void> _loadNext(WidgetTester tester) async {
  await dragUp(tester, _historyScrollView(tester));
  await tester.pumpAndSettle();
}

Future<void> _scrollToTop(WidgetTester tester) async {
  final ScrollController controller = tester
      .widget<SingleChildScrollView>(_historyScrollView(tester))
      .controller!;
  controller.jumpTo(0);
  await tester.pump();
}

Future<void> _loadAll(WidgetTester tester, int expected) async {
  for (int attempt = 0; attempt < 5; attempt++) {
    if (find.byType(LoanCard).evaluate().length >= expected) {
      return;
    }
    await _loadNext(tester);
  }
}

Finder _cardOf(WidgetTester tester, String text) {
  return find.ancestor(of: find.text(text), matching: find.byType(LoanCard));
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byType(FilterButton));
  await tester.pumpAndSettle();
}

Finder _sheetChip(String label) {
  return find.descendant(
    of: find.byType(HistoryFilterSheet),
    matching: find.text(label),
  );
}

Finder _twoRowScroll(String label) {
  return find.ancestor(
    of: _sheetChip(label),
    matching: find.byType(TwoRowChipScroll),
  );
}

ScrollController _chipRowController(WidgetTester tester, String label) {
  final Finder sv = find.descendant(
    of: _twoRowScroll(label),
    matching: find.byWidgetPredicate(
      (Widget w) =>
          w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
    ),
  );
  return tester.widget<SingleChildScrollView>(sv).controller!;
}

Future<void> _tapSheetChip(WidgetTester tester, String label) async {
  final Finder chip = _sheetChip(label);
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

Future<void> _closeSheet(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(HistoryFilterSheet),
      matching: find.byIcon(Icons.close),
    ),
  );
  await tester.pumpAndSettle();
}

bool _chipSelected(WidgetTester tester, String label) {
  return tester
      .widgetList<SelectableChip>(find.byType(SelectableChip))
      .where((SelectableChip chip) => chip.label == label)
      .single
      .selected;
}

Finder _searchField() {
  return find.byType(HistorySearchField);
}

AssetRepository _repository() => AssetRepository(clock: FakeClock());

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Awal tanpa filter menampilkan 12 aset dan 10 kartu', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(_buildApp(_repository()));
    await _openHistory(tester);

    expect(find.text('Riwayat Saya'), findsOneWidget);
    expect(find.text('Cari nama atau kode aset'), findsOneWidget);
    expect(find.byType(FilterButton), findsOneWidget);
    expect(find.byType(HistoryFilterSheet), findsNothing);
    expect(find.text('Semua bulan'), findsNothing);
    expect(find.byType(ActiveFilterChips), findsNothing);
    expect(find.text('12 aset dipinjam'), findsOneWidget);
    expect(find.byType(LoanCard), findsNWidgets(10));
  });

  testWidgets('Ketuk chip langsung ubah filter; menutup sheet tidak membatalkan', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(_buildApp(_repository()));
    await _openHistory(tester);

    await _openSheet(tester);
    expect(find.text('Filter Riwayat'), findsOneWidget);
    expect(find.text('Bulan pinjam'), findsOneWidget);
    expect(find.text('Pilih lebih dari satu'), findsOneWidget);
    expect(find.text('Pilih satu'), findsOneWidget);
    expect(find.text('Terapkan'), findsNothing);
    expect(find.text('Reset'), findsNothing);
    expect(
      find.text('Kosongkan pilihan untuk menampilkan semua bulan.'),
      findsOneWidget,
    );

    await _tapSheetChip(tester, 'Okt 2026');
    await _tapSheetChip(tester, 'Laptop');
    expect(find.byType(HistoryFilterSheet), findsOneWidget);
    expect(_chipSelected(tester, 'Okt 2026'), isTrue);
    expect(_chipSelected(tester, 'Laptop'), isTrue);
    expect(find.byType(ActiveFilterChips), findsOneWidget);
    expect(
      find.descendant(of: find.byType(FilterButton), matching: find.text('2')),
      findsOneWidget,
    );
    expect(find.text('1 aset dipinjam'), findsOneWidget);

    await _closeSheet(tester);

    expect(find.byType(HistoryFilterSheet), findsNothing);
    expect(find.byType(ActiveFilterChips), findsOneWidget);
    expect(find.text('1 aset dipinjam'), findsOneWidget);
    expect(_cardOf(tester, 'HP EliteBook 840 G9'), findsOneWidget);
  });

  testWidgets(
    'Pilih Nov + Okt + Laptop menghasilkan 2 aset; ketuk lagi bulan/status menghapusnya; Semua hapus kategori',
    (WidgetTester tester) async {
      await _setSurface(tester, const Size(800, 600));
      await tester.pumpWidget(_buildApp(_repository()));
      await _openHistory(tester);

      await _openSheet(tester);
      await _tapSheetChip(tester, 'Nov 2026');
      await _tapSheetChip(tester, 'Okt 2026');
      await _tapSheetChip(tester, 'Laptop');

      expect(find.byType(HistoryFilterSheet), findsOneWidget);
      expect(find.byType(ActiveFilterChips), findsOneWidget);
      expect(
        find.descendant(of: find.byType(FilterButton), matching: find.text('3')),
        findsOneWidget,
      );
      expect(find.text('2 aset dipinjam'), findsOneWidget);
      expect(find.byType(LoanCard), findsNWidgets(2));
      expect(_cardOf(tester, 'Dell Latitude 5440'), findsOneWidget);
      expect(_cardOf(tester, 'HP EliteBook 840 G9'), findsOneWidget);

      // Ketuk lagi bulan menghapusnya.
      await _tapSheetChip(tester, 'Okt 2026');
      expect(_chipSelected(tester, 'Okt 2026'), isFalse);
      expect(
        find.descendant(of: find.byType(FilterButton), matching: find.text('2')),
        findsOneWidget,
      );
      expect(find.text('1 aset dipinjam'), findsOneWidget);

      // Semua hapus filter kategori.
      await _tapSheetChip(tester, 'Semua');
      expect(_chipSelected(tester, 'Semua'), isTrue);
      expect(
        find.descendant(of: find.byType(FilterButton), matching: find.text('1')),
        findsOneWidget,
      );
      expect(find.text('1 aset dipinjam'), findsOneWidget);
      await _closeSheet(tester);
    },
  );

  testWidgets('Chip x menghapus satu filter saja', (WidgetTester tester) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(_buildApp(_repository()));
    await _openHistory(tester);

    await _openSheet(tester);
    await _tapSheetChip(tester, 'Nov 2026');
    await _tapSheetChip(tester, 'Okt 2026');
    await _tapSheetChip(tester, 'Laptop');
    await _closeSheet(tester);

    // Urutan chip aktif: Nov, Okt, Laptop.
    await tester.tap(
      find
          .descendant(
            of: find.byType(ActiveFilterChips),
            matching: find.byIcon(Icons.close),
          )
          .at(1),
    );
    await tester.pumpAndSettle();

    expect(find.text('Okt 2026'), findsNothing);
    expect(
      find.descendant(of: find.byType(FilterButton), matching: find.text('2')),
      findsOneWidget,
    );
    expect(find.text('1 aset dipinjam'), findsOneWidget);
    expect(_cardOf(tester, 'Dell Latitude 5440'), findsOneWidget);
  });

  testWidgets('Pencarian debounce dan ikon hapus langsung diterapkan', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(_buildApp(_repository()));
    await _openHistory(tester);

    await tester.enterText(
      find.descendant(of: _searchField(), matching: find.byType(TextField)),
      '  dell  ',
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('2 aset dipinjam'), findsOneWidget);
    expect(find.byType(LoanCard), findsNWidgets(2));
    expect(_cardOf(tester, 'Dell Latitude 5440'), findsOneWidget);
    expect(_cardOf(tester, 'Mouse Wireless Dell'), findsOneWidget);

    await tester.tap(
      find.descendant(of: _searchField(), matching: find.byIcon(Icons.close)),
    );
    await tester.pumpAndSettle();

    expect(find.text('12 aset dipinjam'), findsOneWidget);
    expect(find.byType(LoanCard), findsNWidgets(10));
  });

  testWidgets(
    'Pindah tab mereset filter tetapi mempertahankan teks pencarian',
    (WidgetTester tester) async {
      await _setSurface(tester, const Size(800, 600));
      await tester.pumpWidget(_buildApp(_repository()));
      await _openHistory(tester);

      await _openSheet(tester);
      await _tapSheetChip(tester, 'Okt 2026');
      await _tapSheetChip(tester, 'Laptop');
      await _closeSheet(tester);

      final Finder field = find.descendant(
        of: _searchField(),
        matching: find.byType(TextField),
      );
      await tester.enterText(field, 'xyz');
      await tester.pumpAndSettle();
      expect(
        find.text('Tidak ada aset yang cocok dengan filter.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Dikembalikan'));
      await tester.pumpAndSettle();

      expect(find.byType(ActiveFilterChips), findsNothing);
      expect(
        find.descendant(
          of: find.byType(FilterButton),
          matching: find.text('2'),
        ),
        findsNothing,
      );
      expect(tester.widget<TextField>(field).controller!.text, 'xyz');
      expect(find.text('0 aset dikembalikan'), findsOneWidget);

      await tester.tap(
        find.descendant(of: _searchField(), matching: find.byIcon(Icons.close)),
      );
      await tester.pumpAndSettle();
      expect(find.text('27 aset dikembalikan'), findsOneWidget);
      expect(find.byType(LoanCard), findsNWidgets(10));
    },
  );

  testWidgets('Ganti filter dan tab mengembalikan pagination ke awal', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(_buildApp(_repository()));
    await _openHistory(tester);

    await _loadNext(tester);
    expect(find.byType(LoanCard), findsNWidgets(12));
    await _scrollToTop(tester);

    await _openSheet(tester);
    await _tapSheetChip(tester, 'Okt 2026');
    await _closeSheet(tester);

    expect(find.byType(LoanCard), findsNWidgets(4));
    expect(find.text('4 aset dipinjam'), findsOneWidget);
    expect(
      tester
          .widget<SingleChildScrollView>(_historyScrollView(tester))
          .controller!
          .offset,
      0,
    );

    await tester.tap(
      find
          .descendant(
            of: find.byType(ActiveFilterChips),
            matching: find.byIcon(Icons.close),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await _loadNext(tester);
    expect(find.byType(LoanCard), findsNWidgets(12));
    await _scrollToTop(tester);

    await tester.tap(find.text('Dikembalikan'));
    await tester.pumpAndSettle();
    expect(find.byType(LoanCard), findsNWidgets(10));
    expect(find.text('27 aset dikembalikan'), findsOneWidget);
  });

  testWidgets('Opsi sheet mengikuti tab yang sedang aktif', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(_buildApp(_repository()));
    await _openHistory(tester);

    await tester.tap(find.text('Dikembalikan'));
    await tester.pumpAndSettle();
    await _openSheet(tester);

    expect(find.text('Bulan kembali'), findsOneWidget);
    expect(find.text('Bulan pinjam'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(HistoryFilterSheet),
        matching: find.text('Sep 2026'),
      ),
      findsNothing,
    );
    await _closeSheet(tester);
  });

  testWidgets('Baris chip bulan bisa digeser horizontal dengan mouse', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(360, 700));
    await tester.pumpWidget(_buildApp(_repository()));
    await _openHistory(tester);

    await tester.tap(find.text('Dikembalikan'));
    await tester.pumpAndSettle();
    await _openSheet(tester);

    final Finder sv = find.descendant(
      of: _twoRowScroll('Okt 2026'),
      matching: find.byWidgetPredicate(
        (Widget w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
    );
    final ScrollController controller =
        tester.widget<SingleChildScrollView>(sv).controller!;
    expect(controller.position.maxScrollExtent, greaterThan(0));
    expect(controller.offset, 0);

    await tester.drag(sv, const Offset(-240, 0), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
    await _closeSheet(tester);
  });

  testWidgets('Chip bulan di luar layar bisa dipilih setelah digeser', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(360, 700));
    await tester.pumpWidget(_buildApp(_repository()));
    await _openHistory(tester);

    await tester.tap(find.text('Dikembalikan'));
    await tester.pumpAndSettle();
    await _openSheet(tester);

    final Finder chip = _sheetChip('Feb 2026');
    expect(
      tester.getRect(chip).right,
      greaterThan(360),
      reason: 'Chip Feb 2026 harus awalnya di luar layar',
    );

    await _tapSheetChip(tester, 'Feb 2026');

    expect(_chipSelected(tester, 'Feb 2026'), isTrue);
    expect(_chipRowController(tester, 'Feb 2026').offset, greaterThan(0));
    expect(tester.getRect(chip).right, lessThanOrEqualTo(360));
    await _closeSheet(tester);
  });

  testWidgets('Chip bulan terpilih terlihat saat sheet dibuka kembali', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(360, 700));
    await tester.pumpWidget(_buildApp(_repository()));
    await _openHistory(tester);

    await tester.tap(find.text('Dikembalikan'));
    await tester.pumpAndSettle();
    await _openSheet(tester);
    await _tapSheetChip(tester, 'Feb 2026');
    await _closeSheet(tester);

    await _openSheet(tester);

    expect(_chipSelected(tester, 'Feb 2026'), isTrue);
    expect(_chipRowController(tester, 'Feb 2026').offset, greaterThan(0));
    expect(tester.getRect(_sheetChip('Feb 2026')).right, lessThanOrEqualTo(360));
    expect(tester.getRect(_sheetChip('Feb 2026')).left, greaterThanOrEqualTo(0));
    await _closeSheet(tester);
  });

  testWidgets('Pembagian dua baris bulan (ganjil) dan kedua baris bergeser bersama', (
    WidgetTester tester,
  ) async {
    // Tab Dikembalikan: 9 bulan (ganjil) -> 5 atas, 4 bawah.
    // Urutan: Okt 2026, Jul 2026, Jun 2026, Apr 2026, Feb 2026,
    //         Des 2025, Nov 2025, Sep 2025, Mei 2025.
    await _setSurface(tester, const Size(360, 700));
    await tester.pumpWidget(_buildApp(_repository()));
    await _openHistory(tester);
    await tester.tap(find.text('Dikembalikan'));
    await tester.pumpAndSettle();
    await _openSheet(tester);

    expect(
      tester.getTopLeft(_sheetChip('Okt 2026')).dy,
      tester.getTopLeft(_sheetChip('Feb 2026')).dy,
    );
    expect(
      tester.getTopLeft(_sheetChip('Des 2025')).dy,
      greaterThan(tester.getTopLeft(_sheetChip('Okt 2026')).dy),
    );
    expect(
      tester.getTopLeft(_sheetChip('Des 2025')).dy,
      tester.getTopLeft(_sheetChip('Mei 2025')).dy,
    );

    final Finder sv = find.descendant(
      of: _twoRowScroll('Okt 2026'),
      matching: find.byWidgetPredicate(
        (Widget w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
    );
    final double topBefore = tester.getTopLeft(_sheetChip('Okt 2026')).dx;
    final double bottomBefore = tester.getTopLeft(_sheetChip('Des 2025')).dx;
    await tester.drag(sv, const Offset(-180, 0), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(_sheetChip('Okt 2026')).dx, lessThan(topBefore));
    expect(tester.getTopLeft(_sheetChip('Des 2025')).dx, lessThan(bottomBefore));
    await _closeSheet(tester);

    // Tab Dipinjam: 5 bulan (ganjil) -> 3 atas, 2 bawah.
    // Urutan: Nov 2026, Okt 2026, Sep 2026, Agu 2026, Jul 2026.
    await _setSurface(tester, const Size(800, 700));
    await tester.tap(find.text('Dipinjam'));
    await tester.pumpAndSettle();
    await _openSheet(tester);
    expect(
      tester.getTopLeft(_sheetChip('Nov 2026')).dy,
      tester.getTopLeft(_sheetChip('Sep 2026')).dy,
    );
    expect(
      tester.getTopLeft(_sheetChip('Agu 2026')).dy,
      greaterThan(tester.getTopLeft(_sheetChip('Nov 2026')).dy),
    );
    expect(
      tester.getTopLeft(_sheetChip('Agu 2026')).dy,
      tester.getTopLeft(_sheetChip('Jul 2026')).dy,
    );
    await _closeSheet(tester);
  });

  testWidgets('Sheet filter tidak overflow di layar kecil', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(360, 640));
    await tester.pumpWidget(_buildApp(_repository()));
    await _openHistory(tester);

    await tester.tap(find.text('Dikembalikan'));
    await tester.pumpAndSettle();
    await _openSheet(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Filter Riwayat'), findsOneWidget);
    expect(
      _chipRowController(tester, 'Okt 2026').position.maxScrollExtent,
      greaterThan(0),
    );

    await _closeSheet(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Opsi/pilihan dinormalisasi saat repository berubah saat sheet terbuka', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    final AssetRepository repository = _repository();
    await tester.pumpWidget(_buildApp(repository));
    await _openHistory(tester);

    await _openSheet(tester);
    await _tapSheetChip(tester, 'Nov 2026');
    expect(find.text('12 aset dipinjam'), findsNothing);

    repository.returnAsset('AST-003', now: FakeClock().now());
    await tester.pumpAndSettle();

    expect(find.byType(HistoryFilterSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(HistoryFilterSheet),
        matching: find.text('Nov 2026'),
      ),
      findsNothing,
    );
    await _closeSheet(tester);
    // Setelah normalisasi (bulan hilang -> semua bulan) daftar menyesuaikan.
    expect(find.text('11 aset dipinjam'), findsOneWidget);
  });

  testWidgets('Repository berubah tidak mereset halaman yang sudah dimuat', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    final AssetRepository repository = _repository();
    await tester.pumpWidget(_buildApp(repository));
    await _openHistory(tester);

    await _loadAll(tester, 12);
    expect(find.byType(LoanCard), findsNWidgets(12));

    repository.returnAsset('AST-010', now: FakeClock().now());
    await tester.pumpAndSettle();

    expect(find.byType(LoanCard), findsNWidgets(11));
    expect(find.text('11 aset dipinjam'), findsOneWidget);
    expect(find.text('Riwayat Saya'), findsOneWidget);
  });

  testWidgets('Kembalikan tetap di tab Dipinjam dan mempertahankan filter', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    final AssetRepository repository = _repository();
    await tester.pumpWidget(_buildApp(repository));
    await _openHistory(tester);

    await _openSheet(tester);
    await _tapSheetChip(tester, 'Laptop');
    await _closeSheet(tester);
    expect(find.text('4 aset dipinjam'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: _cardOf(tester, 'Dell Latitude 5440'),
        matching: find.text('Kembalikan'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aset berhasil dikembalikan'), findsOneWidget);
    expect(find.text('3 aset dipinjam'), findsOneWidget);
    expect(find.byType(ActiveFilterChips), findsOneWidget);
    expect(
      find.descendant(of: find.byType(FilterButton), matching: find.text('1')),
      findsOneWidget,
    );
    expect(_cardOf(tester, 'Dell Latitude 5440'), findsNothing);
    expect(find.text('28 aset dikembalikan'), findsNothing);
    expect(repository.assetByCode('AST-003')!.status, AssetStatus.available);
  });

  testWidgets('Kembalikan gagal menampilkan ErrorBanner tanpa mengubah data', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    final AssetRepository repository = _repository();
    await tester.pumpWidget(
      _buildApp(
        repository,
        returnService: const StubAssetReturnService(simulateReturnError: true),
      ),
    );
    await _openHistory(tester);

    await tester.tap(
      find.descendant(
        of: _cardOf(tester, 'Dell Latitude 5440'),
        matching: find.text('Kembalikan'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Koneksi gagal. Pengembalian belum tercatat. Coba lagi.'),
      findsOneWidget,
    );
    expect(repository.assetByCode('AST-003')!.status, AssetStatus.borrowed);
    expect(find.text('Dell Latitude 5440'), findsOneWidget);
  });

  testWidgets('Pinjam dari Detail muncul sebagai pinjaman aktif di Riwayat', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    final AssetRepository repository = _repository();
    await tester.pumpWidget(_buildApp(repository));

    await tester.tap(find.text('MacBook Air M2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pinjam Aset'));
    await tester.pumpAndSettle();

    await _openHistory(tester);
    await _loadAll(tester, 13);

    expect(find.text('MacBook Air M2'), findsOneWidget);
    expect(find.text('13 aset dipinjam'), findsOneWidget);
  });

  testWidgets('Scroll memuat 10 kartu berikutnya tanpa mengubah ringkasan', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(_buildApp(_repository()));
    await _openHistory(tester);

    expect(find.byType(LoanCard), findsNWidgets(10));
    expect(find.text('12 aset dipinjam'), findsOneWidget);

    await _loadNext(tester);

    expect(find.byType(LoanCard), findsNWidgets(12));
    expect(find.text('12 aset dipinjam'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Loader Riwayat tampil saat jeda masih berjalan', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(
      _buildApp(
        _repository(),
        pageDelay: const TimedPageDelay(Duration(milliseconds: 300)),
      ),
    );
    await _openHistory(tester);

    await dragUp(tester, _historyScrollView(tester));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(LoanCard), findsNWidgets(12));
  });
}
