import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application_1/core/filter/widgets/active_filter_bar.dart';
import 'package:flutter_application_1/core/filter/widgets/filter_button.dart';
import 'package:flutter_application_1/core/pagination/page_delay.dart';
import 'package:flutter_application_1/features/asset/data/asset_repository.dart';
import 'package:flutter_application_1/features/asset/data/asset_repository_scope.dart';
import 'package:flutter_application_1/features/asset/pages/asset_list_page.dart';
import 'package:flutter_application_1/features/asset/widgets/asset_filter_sheet.dart';
import 'package:flutter_application_1/features/history/pages/history_page.dart'
    show kDefaultHistorySearchDebounce;

import 'helpers/fake_clock.dart';
import 'helpers/pagination_helpers.dart';

Widget _buildApp(
  AssetRepository repository,
  PageDelay delay, {
  Duration searchDebounce = zeroSearchDebounce,
}) {
  return MaterialApp(
    home: AssetRepositoryScope(
      repository: repository,
      child: AssetListPage(
        pageDelay: delay,
        searchDebounce: searchDebounce,
      ),
    ),
  );
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Finder _assetListView() {
  return find.byWidgetPredicate(
    (Widget widget) => widget is ListView && widget.scrollDirection == Axis.vertical,
  );
}

/// ListView.separated membuat 2*item - 1 children (item + separator).
int _itemCount(WidgetTester tester) {
  final SliverChildBuilderDelegate delegate =
      tester.widget<ListView>(_assetListView()).childrenDelegate
          as SliverChildBuilderDelegate;
  final int children = delegate.childCount ?? 0;
  return children == 0 ? 0 : (children + 1) ~/ 2;
}

Future<void> _loadNext(WidgetTester tester) async {
  await dragUp(tester, _assetListView());
  await tester.pumpAndSettle();
}

Future<void> _openFilterSheet(WidgetTester tester) async {
  await tester.tap(find.byType(FilterButton));
  await tester.pumpAndSettle();
}

Finder _sheetChip(String label) {
  return find.descendant(
    of: find.byType(AssetFilterSheet),
    matching: find.text(label),
  );
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
      of: find.byType(AssetFilterSheet),
      matching: find.byIcon(Icons.close),
    ),
  );
  await tester.pumpAndSettle();
}

AssetRepository _repository() => AssetRepository(clock: FakeClock());

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Awal hanya memuat 10 item dan tidak ada loader', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(_buildApp(_repository(), zeroPageDelay));
    await tester.pumpAndSettle();

    expect(_itemCount(tester), 10);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Scroll memuat 10 item berikutnya', (WidgetTester tester) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(_buildApp(_repository(), zeroPageDelay));
    await tester.pumpAndSettle();

    await _loadNext(tester);

    expect(_itemCount(tester), 20);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Loader tampil saat jeda masih berjalan', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(
      _buildApp(
        _repository(),
        const TimedPageDelay(Duration(milliseconds: 300)),
      ),
    );
    await tester.pumpAndSettle();

    await dragUp(tester, find.byType(ListView));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(_itemCount(tester), 20);
  });

  testWidgets('Semua item dimuat otomatis bila konten belum bisa di-scroll', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 2500));
    await tester.pumpWidget(_buildApp(_repository(), zeroPageDelay));
    await tester.pumpAndSettle();

    expect(_itemCount(tester), 25);
  });

  testWidgets(
    'Filter status langsung berlaku, reset pagination, dan tidak batal saat sheet ditutup',
    (WidgetTester tester) async {
      await _setSurface(tester, const Size(800, 600));
      await tester.pumpWidget(_buildApp(_repository(), zeroPageDelay));
      await tester.pumpAndSettle();

      await _loadNext(tester);
      expect(_itemCount(tester), 20);

      await _openFilterSheet(tester);
      await _tapSheetChip(tester, 'Dipinjam');

      // Langsung berubah tanpa menutup sheet: badge, chip aktif, daftar reset.
      expect(find.byType(AssetFilterSheet), findsOneWidget);
      expect(
        find.descendant(of: find.byType(FilterButton), matching: find.text('1')),
        findsOneWidget,
      );
      expect(find.byType(ActiveFilterBar), findsOneWidget);
      expect(_itemCount(tester), 10);
      expect(
        tester.widget<ListView>(_assetListView().first).controller!.offset,
        0,
      );

      await _closeSheet(tester);
      expect(find.byType(ActiveFilterBar), findsOneWidget);
      expect(_itemCount(tester), 10);
    },
  );

  testWidgets('Pinjam dari Detail tidak mereset jumlah item termuat', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    final AssetRepository repository = _repository();
    await tester.pumpWidget(_buildApp(repository, zeroPageDelay));
    await tester.pumpAndSettle();

    await _loadNext(tester);
    expect(_itemCount(tester), 20);

    tester.widget<ListView>(_assetListView().first).controller!.jumpTo(0);
    await tester.pump();

    await tester.tap(find.text('ThinkPad X1 Carbon Gen 11'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pinjam Aset'));
    await tester.pumpAndSettle();

    expect(_itemCount(tester), 20);
  });

  testWidgets(
    'Chip aktif x menghapus filter; ketuk lagi status/kategori di sheet menghapus',
    (WidgetTester tester) async {
      await _setSurface(tester, const Size(800, 600));
      await tester.pumpWidget(_buildApp(_repository(), zeroPageDelay));
      await tester.pumpAndSettle();

      await _openFilterSheet(tester);
      await _tapSheetChip(tester, 'Maintenance');
      await _tapSheetChip(tester, 'Laptop');
      expect(
        find.descendant(of: find.byType(FilterButton), matching: find.text('2')),
        findsOneWidget,
      );

      // Ketuk lagi menghapus langsung.
      await _tapSheetChip(tester, 'Maintenance');
      expect(
        find.descendant(of: find.byType(FilterButton), matching: find.text('1')),
        findsOneWidget,
      );
      await _tapSheetChip(tester, 'Semua');
      expect(find.byType(ActiveFilterBar), findsNothing);
      await _closeSheet(tester);

      await _openFilterSheet(tester);
      await _tapSheetChip(tester, 'Dipinjam');
      await _closeSheet(tester);
      expect(find.byType(ActiveFilterBar), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(ActiveFilterBar),
          matching: find.byIcon(Icons.close),
        ).first,
      );
      await tester.pumpAndSettle();
      expect(find.byType(ActiveFilterBar), findsNothing);
    },
  );

  testWidgets('Pencarian debounce 300ms lalu reset pagination', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(
      _buildApp(
        _repository(),
        zeroPageDelay,
        searchDebounce: kDefaultHistorySearchDebounce,
      ),
    );
    await tester.pumpAndSettle();

    await _loadNext(tester);
    expect(_itemCount(tester), 20);

    await tester.enterText(find.byType(TextField), 'dell');
    await tester.pump(const Duration(milliseconds: 100));
    expect(_itemCount(tester), 20);

    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(_itemCount(tester), 4);
    expect(
      tester.widget<ListView>(_assetListView().first).controller!.offset,
      0,
    );
  });

  testWidgets('Hasil kosong karena filter menampilkan empty state', (
    WidgetTester tester,
  ) async {
    await _setSurface(tester, const Size(800, 600));
    await tester.pumpWidget(_buildApp(_repository(), zeroPageDelay));
    await tester.pumpAndSettle();

    await _openFilterSheet(tester);
    await _tapSheetChip(tester, 'Maintenance');
    await _tapSheetChip(tester, 'Laptop');
    await _closeSheet(tester);

    expect(_assetListView(), findsNothing);
    expect(
      find.text('Tidak ada aset yang cocok dengan filter.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Filter Tersedia lalu Pinjam: kartu hilang tanpa lompat ke atas',
    (WidgetTester tester) async {
      await _setSurface(tester, const Size(800, 800));
      final AssetRepository repository = _repository();
      await tester.pumpWidget(_buildApp(repository, zeroPageDelay));
      await tester.pumpAndSettle();

      await _openFilterSheet(tester);
      await _tapSheetChip(tester, 'Tersedia');
      await _closeSheet(tester);
      expect(find.text('ThinkPad X1 Carbon Gen 11'), findsOneWidget);

      final ScrollController controller =
          tester.widget<ListView>(_assetListView().first).controller!;
      controller.jumpTo(20);
      await tester.pump();
      expect(controller.offset, 20);

      await tester.tap(find.text('ThinkPad X1 Carbon Gen 11'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pinjam Aset'));
      await tester.pumpAndSettle();

      expect(find.text('ThinkPad X1 Carbon Gen 11'), findsNothing);
      expect(controller.offset, 20);
    },
  );
}
