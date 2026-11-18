import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/asset/data/asset_repository_scope.dart';
import 'features/auth/data/auth_scope.dart';
import 'features/auth/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

/// Root aplikasi. Halaman awalnya adalah "Login".
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      child: AssetRepositoryScope(
        child: MaterialApp(
          title: 'Daftar Aset',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const LoginPage(),
        ),
      ),
    );
  }
}
