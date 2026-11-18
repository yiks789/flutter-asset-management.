import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application_1/core/filter/widgets/two_row_chip_scroll.dart';
import 'package:flutter_application_1/features/asset/data/asset_repository.dart';
import 'package:flutter_application_1/features/asset/data/asset_repository_scope.dart';
import 'package:flutter_application_1/features/asset/models/asset_item.dart';
import 'package:flutter_application_1/features/asset/models/asset_status.dart';
import 'package:flutter_application_1/features/asset/utils/asset_filters.dart';
import 'package:flutter_application_1/features/asset/widgets/asset_filter_sheet.dart';

import 'helpers/fake_clock.dart';

AssetRepository _repoWithCategories(List<String> categories) {
  return AssetRepository(
    assets: <AssetItem>[
      for (int i = 0; i < categories.length; i++)
        AssetItem(
          id: 'A$i',
          name: 'Asset $i',
          code: 'C$i',
          category: categories[i],
          status: AssetStatus.available,
        ),
    ],
    clock: FakeClock(),
  );
}

class _SheetHost extends StatefulWidget {
  const _SheetHost({
    required this.repository,
    this.initialStatuses = const <AssetStatus>{},
    this.initialCategory,
  });

  final AssetRepository repository;
  final Set<AssetStatus> initialStatuses;
  final String? initialCategory;

  @override
  State<_SheetHost> createState() => _SheetHostState();
}

class _SheetHostState extends State<_SheetHost> {
  late Set<AssetStatus> statuses;
  String? category;
  int changeCount = 0;
  final ValueNotifier<int> rev = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    statuses = Set<AssetStatus>.from(widget.initialStatuses);
    category = widget.initialCategory;
  }

  @override
  void dispose() {
    rev.dispose();
    super.dispose();
  }

  void onChanged(Set<AssetStatus> s, String? c) {
    setState(() {
      statuses = Set<AssetStatus>.from(s);
      category = c;
      changeCount++;
    });
    rev.value++;
  }

  void open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ValueListenableBuilder<int>(
        valueListenable: rev,
        builder: (BuildContext context, int _, Widget? __) {
          return AssetFilterSheet(
            repository: widget.repository,
            selectedStatuses: statuses,
            selectedCategory: category,
            onChanged: onChanged,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}

Widget _buildApp(AssetRepository repository, {
  Set<AssetStatus> initialStatuses = const <AssetStatus>{},
  String? initialCategory,
}) {
  return MaterialApp(
    home: AssetRepositoryScope(
      repository: repository,
      child: _SheetHost(
        repository: repository,
        initialStatuses: initialStatuses,
        initialCategory: initialCategory,
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  final _SheetHostState state = tester.state<_SheetHostState>(find.byType(_SheetHost));
  state.open(tester.element(find.byType(Scaffold)));
  await tester.pumpAndSettle();
}

Finder _sheetChip(String label) {
  return find.descendant(
    of: find.byType(AssetFilterSheet),
    matching: find.text(label),
  );
}

Finder _twoRowScroll(String label) {
  return find.ancestor(
    of: _sheetChip(label),
    matching: find.byType(TwoRowChipScroll),
  );
}

ScrollController _scrollController(WidgetTester tester, String label) {
  final Finder sv = find.descendant(
    of: _twoRowScroll(label),
    matching: find.byWidgetPredicate(
      (Widget w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
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

bool _chipSelected(WidgetTester tester, String label) {
  final Finder icon = find.descendant(
    of: find.ancestor(of: _sheetChip(label), matching: find.byType(InkWell)),
    matching: find.byIcon(Icons.check_box),
  );
  final Finder icon2 = find.descendant(
    of: find.ancestor(of: _sheetChip(label), matching: find.byType(InkWell)),
    matching: find.byIcon(Icons.radio_button_checked),
  );
  return icon.evaluate().isNotEmpty || icon2.evaluate().isNotEmpty;
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('ketuk chip langsung ubah filter tanpa menutup sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp(AssetRepository(clock: FakeClock())));
    await _open(tester);
    final _SheetHostState state = tester.state<_SheetHostState>(find.byType(_SheetHost));

    expect(find.text('Filter Aset'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Pilih lebih dari satu'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Pilih satu'), findsOneWidget);
    expect(find.text('Kosongkan pilihan untuk menampilkan semua status.'), findsOneWidget);
    expect(find.text('Terapkan'), findsNothing);
    expect(find.text('Reset'), findsNothing);

    await _tapSheetChip(tester, 'Tersedia');

    expect(find.byType(AssetFilterSheet), findsOneWidget);
    expect(state.changeCount, 1);
    expect(state.statuses, <AssetStatus>{AssetStatus.available});
    expect(_chipSelected(tester, 'Tersedia'), isTrue);

    await _tapSheetChip(tester, 'Maintenance');
    await _tapSheetChip(tester, 'Jaringan');
    expect(state.statuses, <AssetStatus>{AssetStatus.available, AssetStatus.maintenance});
    expect(state.category, 'Jaringan');
    expect(state.changeCount, 3);
  });

  testWidgets('menutup sheet tidak membatalkan filter', (WidgetTester tester) async {
    await tester.pumpWidget(_buildApp(AssetRepository(clock: FakeClock())));
    await _open(tester);
    final _SheetHostState state = tester.state<_SheetHostState>(find.byType(_SheetHost));

    await _tapSheetChip(tester, 'Dipinjam');
    await tester.tap(
      find.descendant(of: find.byType(AssetFilterSheet), matching: find.byIcon(Icons.close)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AssetFilterSheet), findsNothing);
    expect(state.statuses, <AssetStatus>{AssetStatus.borrowed});
  });

  testWidgets('ketuk lagi chip status menghapusnya; Semua hapus kategori', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp(AssetRepository(clock: FakeClock())));
    await _open(tester);
    final _SheetHostState state = tester.state<_SheetHostState>(find.byType(_SheetHost));

    await _tapSheetChip(tester, 'Tersedia');
    await _tapSheetChip(tester, 'Tersedia');
    expect(state.statuses, isEmpty);

    await _tapSheetChip(tester, 'Laptop');
    expect(state.category, 'Laptop');
    await _tapSheetChip(tester, 'Semua');
    expect(state.category, isNull);
  });

  testWidgets('kategori memuat Semua + kategori aset urut abjad', (
    WidgetTester tester,
  ) async {
    final AssetRepository repository = AssetRepository(clock: FakeClock());
    await tester.pumpWidget(_buildApp(repository));
    await _open(tester);

    expect(_sheetChip('Semua'), findsOneWidget);
    for (final String category in categoriesForAssets(repository.assets)) {
      expect(_sheetChip(category), findsOneWidget);
    }
  });

  testWidgets('pembagian dua baris: ganjil, genap, dan 1 chip', (
    WidgetTester tester,
  ) async {
    // Status: 3 chip -> 2 atas, 1 bawah (ganjil)
    await tester.pumpWidget(_buildApp(AssetRepository(clock: FakeClock())));
    await _open(tester);
    expect(tester.getTopLeft(_sheetChip('Tersedia')).dy,
        tester.getTopLeft(_sheetChip('Dipinjam')).dy);
    expect(tester.getTopLeft(_sheetChip('Maintenance')).dy,
        greaterThan(tester.getTopLeft(_sheetChip('Tersedia')).dy));

    await tester.tap(
      find.descendant(of: find.byType(AssetFilterSheet), matching: find.byIcon(Icons.close)),
    );
    await tester.pumpAndSettle();

    // Kategori: Semua + 3 = 4 chip -> 2 atas, 2 bawah (genap)
    await tester.pumpWidget(_buildApp(_repoWithCategories(<String>['Laptop', 'Tablet', 'Aksesoris'])));
    await _open(tester);
    expect(tester.getTopLeft(_sheetChip('Semua')).dy,
        tester.getTopLeft(_sheetChip('Aksesoris')).dy);
    expect(tester.getTopLeft(_sheetChip('Laptop')).dy,
        greaterThan(tester.getTopLeft(_sheetChip('Semua')).dy));
    expect(tester.getTopLeft(_sheetChip('Laptop')).dy,
        tester.getTopLeft(_sheetChip('Tablet')).dy);

    await tester.tap(
      find.descendant(of: find.byType(AssetFilterSheet), matching: find.byIcon(Icons.close)),
    );
    await tester.pumpAndSettle();

    // Kategori: Semua saja = 1 chip -> satu baris
    await tester.pumpWidget(_buildApp(_repoWithCategories(const <String>[])));
    await _open(tester);
    final Finder kategoriScroll = _twoRowScroll('Semua');
    final Column column = tester.widget<Column>(
      find.descendant(of: kategoriScroll, matching: find.byType(Column)).first,
    );
    final int rowContainers = column.children
        .where((Widget w) => w is SizedBox && w.height == 44)
        .length;
    expect(rowContainers, 1);
  });

  testWidgets('kedua baris bergeser bersama', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildApp(AssetRepository(clock: FakeClock())));
    await _open(tester);

    final Finder scroll = find.descendant(
      of: _twoRowScroll('Semua'),
      matching: find.byWidgetPredicate(
        (Widget w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
    );
    final ScrollController controller = tester.widget<SingleChildScrollView>(scroll).controller!;
    expect(controller.position.maxScrollExtent, greaterThan(0));
    final double topBefore = tester.getTopLeft(_sheetChip('Semua')).dx;
    final double bottomBefore = tester.getTopLeft(_sheetChip('Laptop')).dx;

    await tester.drag(scroll, const Offset(-180, 0), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
    expect(tester.getTopLeft(_sheetChip('Semua')).dx, lessThan(topBefore));
    expect(tester.getTopLeft(_sheetChip('Laptop')).dx, lessThan(bottomBefore));
  });

  testWidgets('auto-scroll ke chip terpilih di baris atas dan bawah', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Baris bawah kategori: dummy aset punya 6 kategori -> "Semua"+6=7, Tablet di baris bawah.
    await tester.pumpWidget(_buildApp(
      AssetRepository(clock: FakeClock()),
      initialCategory: 'Tablet',
    ));
    await _open(tester);
    expect(_scrollController(tester, 'Tablet').offset, greaterThan(0));
    expect(tester.getRect(_sheetChip('Tablet')).left, greaterThanOrEqualTo(0));
    expect(tester.getRect(_sheetChip('Tablet')).right, lessThanOrEqualTo(360));

    await tester.tap(
      find.descendant(of: find.byType(AssetFilterSheet), matching: find.byIcon(Icons.close)),
    );
    await tester.pumpAndSettle();

    // Baris atas: 13 chip (Semua + 12 kategori) -> 7 atas, 6 bawah.
    // "Kategori F Pilihan" berada di baris atas (index 6, terakhir baris atas)
    // dan di luar layar kanan pada lebar 360.
    await tester.pumpWidget(_buildApp(
      _repoWithCategories(<String>[
        'Kategori A',
        'Kategori B',
        'Kategori C',
        'Kategori D',
        'Kategori E',
        'Kategori F Pilihan',
        'Kategori G',
        'Kategori H',
        'Kategori I',
        'Kategori J',
        'Kategori K',
        'Kategori L',
      ]),
      initialCategory: 'Kategori F Pilihan',
    ));
    await _open(tester);
    expect(
      _scrollController(tester, 'Kategori F Pilihan').offset,
      greaterThan(0),
    );
    expect(
      tester.getRect(_sheetChip('Kategori F Pilihan')).left,
      greaterThanOrEqualTo(0),
    );
    expect(
      tester.getRect(_sheetChip('Kategori F Pilihan')).right,
      lessThanOrEqualTo(360),
    );
  });
}

