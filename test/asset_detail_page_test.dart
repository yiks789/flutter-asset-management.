import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application_1/features/asset/data/asset_borrow_service.dart';
import 'package:flutter_application_1/features/asset/data/asset_repository.dart';
import 'package:flutter_application_1/features/asset/data/asset_repository_scope.dart';
import 'package:flutter_application_1/features/asset/detail/pages/asset_detail_page.dart';
import 'package:flutter_application_1/features/asset/models/asset_item.dart';
import 'package:flutter_application_1/features/asset/models/asset_status.dart';

import 'helpers/fake_clock.dart';

const AssetItem _asset = AssetItem(
  id: 'AST-002',
  name: 'MacBook Air M2',
  code: 'AST-002',
  category: 'Laptop',
  status: AssetStatus.available,
);

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Detail menampilkan data aset dan tombol aktif', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: AssetDetailPage(asset: _asset)));

    expect(find.text('Detail Aset'), findsOneWidget);
    expect(find.text('MacBook Air M2'), findsOneWidget);
    expect(find.text('AST-002'), findsNWidgets(2));
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('AVAILABLE'), findsNWidgets(2));
    expect(find.text('Pinjam Aset'), findsOneWidget);

    final ElevatedButton button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('Aset tidak tersedia membuat tombol disabled', (
    WidgetTester tester,
  ) async {
    final AssetItem asset = _asset.copyWith(status: AssetStatus.borrowed);
    await tester.pumpWidget(MaterialApp(home: AssetDetailPage(asset: asset)));

    final ElevatedButton button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(button.onPressed, isNull);
    expect(find.text('BORROWED'), findsNWidgets(2));
  });

  testWidgets('Conflict 409 menampilkan ErrorBanner dengan kode dinamis', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AssetDetailPage(
          asset: _asset,
          borrowService: const StubAssetBorrowService(simulateConflict: true),
        ),
      ),
    );

    await tester.tap(find.text('Pinjam Aset'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Aset AST-002 sudah dipinjam pengguna lain. Muat ulang daftar.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('Aset AST-003 selalu mengembalikan 409', (
    WidgetTester tester,
  ) async {
    final AssetItem asset = _asset.copyWith(id: 'AST-003', code: 'AST-003');
    await tester.pumpWidget(MaterialApp(home: AssetDetailPage(asset: asset)));

    await tester.tap(find.text('Pinjam Aset'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Aset AST-003 sudah dipinjam pengguna lain. Muat ulang daftar.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Sukses meminjam mengembalikan hasil true ke halaman daftar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _DetailHarness(service: const StubAssetBorrowService()),
      ),
    );

    await tester.tap(find.text('Buka detail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pinjam Aset'));
    await tester.pumpAndSettle();

    expect(find.text('Hasil: true'), findsOneWidget);
  });

  testWidgets('Sukses meminjam mencatat loan aktif baru di repository', (
    WidgetTester tester,
  ) async {
    final AssetRepository repository = AssetRepository(clock: FakeClock());

    await tester.pumpWidget(
      MaterialApp(
        home: AssetRepositoryScope(
          repository: repository,
          child: AssetDetailPage(asset: _asset),
        ),
      ),
    );

    await tester.tap(find.text('Pinjam Aset'));
    await tester.pumpAndSettle();

    expect(
      repository.loans.where(
        (loan) => loan.assetCode == 'AST-002' && loan.isActive,
      ),
      hasLength(1),
    );
    expect(repository.assetByCode('AST-002')!.status, AssetStatus.borrowed);
  });

  testWidgets('Dell setelah dikembalikan tetap memicu 409 saat dipinjam', (
    WidgetTester tester,
  ) async {
    final AssetRepository repository = AssetRepository(clock: FakeClock());
    repository.returnAsset('AST-003', now: FakeClock().now());
    final AssetItem dell = repository.assetByCode('AST-003')!;
    expect(dell.status, AssetStatus.available);

    await tester.pumpWidget(
      MaterialApp(
        home: AssetRepositoryScope(
          repository: repository,
          child: AssetDetailPage(asset: dell),
        ),
      ),
    );

    await tester.tap(find.text('Pinjam Aset'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Aset AST-003 sudah dipinjam pengguna lain. Muat ulang daftar.',
      ),
      findsOneWidget,
    );
    expect(repository.assetByCode('AST-003')!.status, AssetStatus.available);
  });
}

/// Host kecil untuk menangkap hasil Navigator.pop dari halaman detail.
class _DetailHarness extends StatefulWidget {
  const _DetailHarness({required this.service});

  final AssetBorrowService service;

  @override
  State<_DetailHarness> createState() => _DetailHarnessState();
}

class _DetailHarnessState extends State<_DetailHarness> {
  String _result = '-';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text('Hasil: $_result'),
          ElevatedButton(
            onPressed: () async {
              final bool? value = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (BuildContext context) => AssetDetailPage(
                    asset: _asset,
                    borrowService: widget.service,
                  ),
                ),
              );
              if (mounted) {
                setState(() => _result = value.toString());
              }
            },
            child: const Text('Buka detail'),
          ),
        ],
      ),
    );
  }
}
