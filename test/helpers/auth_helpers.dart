import 'package:flutter/widgets.dart';

import 'package:flutter_application_1/features/auth/data/auth_controller.dart';
import 'package:flutter_application_1/features/auth/data/auth_scope.dart';
import 'package:flutter_application_1/features/auth/data/auth_user.dart';

/// Scope dengan user demo sudah login, untuk test yang langsung membuka Shell.
Widget signedInAuthScope({required Widget child, AuthController? controller}) {
  return AuthScope(
    controller: controller ?? AuthController(initialUser: AuthUser.demo),
    child: child,
  );
}
