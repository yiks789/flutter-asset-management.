import 'package:flutter/widgets.dart';

import 'auth_controller.dart';
import 'auth_service.dart';

/// Menyediakan [AuthController] ke Login, Shell, dan Profil.
class AuthScope extends StatefulWidget {
  const AuthScope({
    super.key,
    this.controller,
    AuthService? service,
    required this.child,
  }) : _service = service;

  final AuthController? controller;
  final AuthService? _service;
  final Widget child;

  @override
  State<AuthScope> createState() => _AuthScopeState();
}

class _AuthScopeState extends State<AuthScope> {
  late final AuthController _controller =
      widget.controller ?? AuthController(service: widget._service);

  @override
  Widget build(BuildContext context) {
    return _InheritedAuth(controller: _controller, child: widget.child);
  }
}

class _InheritedAuth extends InheritedNotifier<AuthController> {
  const _InheritedAuth({
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedAuth>()
        ?.notifier;
  }
}

/// Ambil controller terdekat. Harus dipanggil di bawah [AuthScope].
AuthController authControllerOf(BuildContext context) {
  final AuthController? controller = _InheritedAuth.maybeOf(context);
  assert(controller != null, 'AuthScope tidak ditemukan.');
  return controller!;
}

/// Versi opsional untuk widget yang bisa dipakai tanpa scope.
AuthController? maybeAuthControllerOf(BuildContext context) {
  return _InheritedAuth.maybeOf(context);
}
