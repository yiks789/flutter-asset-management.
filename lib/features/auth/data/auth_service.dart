import 'auth_user.dart';

/// Error auth dengan pesan siap tampil di ErrorBanner.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

class AuthInvalidCredentialsException extends AuthException {
  const AuthInvalidCredentialsException() : super('Email atau password salah.');
}

class AuthNetworkException extends AuthException {
  const AuthNetworkException() : super('Koneksi gagal. Coba lagi.');
}

/// Kontrak login. Bisa diganti implementasi HTTP di tahap berikutnya.
abstract interface class AuthService {
  Future<AuthUser> signIn({required String email, required String password});
}

/// Stub login untuk akun demo. Default sukses untuk kredensial demo.
class StubAuthService implements AuthService {
  const StubAuthService({this.simulateNetworkError = false});

  static const String demoEmail = 'rina@demo.test';
  static const String demoPassword = 'demo1234';

  final bool simulateNetworkError;

  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    if (simulateNetworkError) {
      return Future<AuthUser>.error(const AuthNetworkException());
    }
    if (email.trim() == demoEmail && password == demoPassword) {
      return Future<AuthUser>.value(AuthUser.demo);
    }
    return Future<AuthUser>.error(const AuthInvalidCredentialsException());
  }
}
