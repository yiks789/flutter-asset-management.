import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'auth_user.dart';

/// Sesi login in-memory. Tidak ada persistensi maupun package tambahan.
class AuthController extends ChangeNotifier {
  AuthController({AuthService? service, AuthUser? initialUser})
    : _service = service ?? const StubAuthService(),
      _user = initialUser;

  final AuthService _service;
  AuthUser? _user;

  AuthUser? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> signIn({required String email, required String password}) async {
    final AuthUser user = await _service.signIn(
      email: email,
      password: password,
    );
    _user = user;
    notifyListeners();
  }

  void signOut() {
    if (_user == null) {
      return;
    }
    _user = null;
    notifyListeners();
  }
}
