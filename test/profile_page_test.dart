import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application_1/core/navigation/app_shell.dart';
import 'package:flutter_application_1/features/asset/data/asset_repository.dart';
import 'package:flutter_application_1/features/asset/data/asset_repository_scope.dart';
import 'package:flutter_application_1/features/history/widgets/loan_card.dart';

import 'helpers/auth_helpers.dart';
import 'helpers/fake_clock.dart';

Widget _buildApp(AssetRepository repository) {
  return signedInAuthScope(
    child: AssetRepositoryScope(
      repository: repository,
      clock: FakeClock(),
      child: MaterialApp(home: AppShell(historyClock: FakeClock())),
    ),
  );
}

Future<void> _goTo(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

AssetRepository _repository() => AssetRepository(clock: FakeClock());

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Profil menampilkan data user dan statistik awal 12 dan 27', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp(_repository()));
    await _goTo(tester, 'Profil');

    expect(find.text('Profil'), findsNWidgets(2));
    expect(find.text('RP'), findsOneWidget);
    expect(find.text('Rina Putri'), findsNWidgets(2));
    expect(find.text('rina@demo.test'), findsNWidgets(2));
    expect(find.text('Finance'), findsOneWidget);
    expect(find.text('Sedang dipinjam'), findsOneWidget);
    expect(find.text('Dikembalikan'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('27'), findsOneWidget);
  });

  testWidgets('Statistik berubah setelah Pinjam dari Detail', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp(_repository()));

    await _goTo(tester, 'Aset');
    await tester.tap(find.text('MacBook Air M2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pinjam Aset'));
    await tester.pumpAndSettle();

    await _goTo(tester, 'Profil');
    expect(find.text('13'), findsOneWidget);
    expect(find.text('27'), findsOneWidget);
  });

  testWidgets('Statistik berubah setelah Kembalikan dari Riwayat', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp(_repository()));

    await _goTo(tester, 'Riwayat');
    final Finder dellCard = find.ancestor(
      of: find.text('Dell Latitude 5440'),
      matching: find.byType(LoanCard),
    );
    await tester.tap(
      find.descendant(of: dellCard, matching: find.text('Kembalikan')),
    );
    await tester.pumpAndSettle();

    await _goTo(tester, 'Profil');
    expect(find.text('11'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);
  });

  testWidgets('Keluar kembali ke Login tanpa crash saat user dihapus', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp(_repository()));
    await _goTo(tester, 'Profil');

    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Rina Putri'), findsNothing);
  });
}
