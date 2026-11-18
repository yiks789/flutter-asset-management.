import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application_1/main.dart';

Future<void> _login(WidgetTester tester) async {
  await tester.tap(find.text('Masuk'));
  await tester.pumpAndSettle();
}

/// ListView.separated membuat 2*item - 1 children (item + separator).
int _itemCount(WidgetTester tester) {
  final SliverChildBuilderDelegate delegate =
      tester.widget<ListView>(find.byType(ListView)).childrenDelegate
          as SliverChildBuilderDelegate;
  final int children = delegate.childCount ?? 0;
  return children == 0 ? 0 : (children + 1) ~/ 2;
}

void main() {
  setUp(() {
    // Hindari request font ke jaringan saat menjalankan test.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Daftar Aset menampilkan header dan 10 kartu awal', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    expect(find.text('Selamat datang'), findsOneWidget);
    await _login(tester);

    expect(find.text('Daftar Aset'), findsOneWidget);
    expect(_itemCount(tester), 10);
    expect(find.text('MacBook Air M2'), findsOneWidget);
    expect(find.text('Dell Latitude 5440'), findsOneWidget);
    expect(find.text('Proyektor Epson EB-X06'), findsNothing);
  });

  testWidgets('Pencarian menemukan aset di luar halaman pertama', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _login(tester);

    await tester.enterText(find.byType(TextField), 'Proyektor');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Proyektor Epson EB-X06'), findsOneWidget);
    expect(_itemCount(tester), 1);
  });
}
