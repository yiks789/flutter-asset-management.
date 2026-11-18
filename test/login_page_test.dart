import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application_1/features/asset/data/asset_repository_scope.dart';
import 'package:flutter_application_1/features/auth/data/auth_scope.dart';
import 'package:flutter_application_1/features/auth/data/auth_service.dart';
import 'package:flutter_application_1/features/auth/data/auth_user.dart';
import 'package:flutter_application_1/features/auth/pages/login_page.dart';

Widget _buildApp({AuthService? service}) {
  return AuthScope(
    service: service,
    child: AssetRepositoryScope(child: MaterialApp(home: const LoginPage())),
  );
}

Future<void> _fill(WidgetTester tester, int index, String value) async {
  await tester.enterText(find.byType(TextField).at(index), value);
  await tester.pump();
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Login demo sukses membuka Daftar Aset', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp());

    expect(find.text('Selamat datang'), findsOneWidget);
    expect(
      find.text('Masuk untuk meminjam dan mengembalikan aset kantor.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Daftar Aset'), findsOneWidget);
    expect(find.text('Selamat datang'), findsNothing);
  });

  testWidgets('Kredensial salah menampilkan ErrorBanner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp());

    await _fill(tester, 0, 'salah@demo.test');
    await _fill(tester, 1, 'salah1234');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Email atau password salah.'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Daftar Aset'), findsNothing);
  });

  testWidgets('Validasi email kosong dan format salah', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp());

    await _fill(tester, 0, '');
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    expect(find.text('Email wajib diisi.'), findsOneWidget);

    await _fill(tester, 0, 'bukan-email');
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    expect(find.text('Format email tidak valid.'), findsOneWidget);
  });

  testWidgets('Validasi password kosong', (WidgetTester tester) async {
    await tester.pumpWidget(_buildApp());

    await _fill(tester, 1, '');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Password wajib diisi.'), findsOneWidget);
  });

  testWidgets('simulateNetworkError menampilkan pesan koneksi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(service: const StubAuthService(simulateNetworkError: true)),
    );

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Koneksi gagal. Coba lagi.'), findsOneWidget);
  });

  testWidgets('Tombol Masuk menampilkan loading saat request berjalan', (
    WidgetTester tester,
  ) async {
    final _SlowAuthService service = _SlowAuthService();
    await tester.pumpWidget(_buildApp(service: service));

    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final ElevatedButton button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(button.onPressed, isNull);

    service.complete();
    await tester.pumpAndSettle();

    expect(find.text('Daftar Aset'), findsOneWidget);
  });
}

/// AuthService dengan Completer untuk mengamati state loading.
class _SlowAuthService implements AuthService {
  final Completer<AuthUser> _completer = Completer<AuthUser>();

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete(AuthUser.demo);
    }
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    return _completer.future;
  }
}
