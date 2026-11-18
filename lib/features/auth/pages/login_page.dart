import 'package:flutter/material.dart';

import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../asset/detail/widgets/error_banner.dart';
import '../data/auth_controller.dart';
import '../data/auth_scope.dart';
import '../data/auth_service.dart';
import '../utils/auth_validators.dart';
import '../widgets/app_logo_badge.dart';
import '../widgets/auth_text_field.dart';

/// Halaman login. Tanpa bottom nav; menggantikan diri dengan AppShell.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(
    text: StubAuthService.demoEmail,
  );
  final TextEditingController _passwordController = TextEditingController(
    text: StubAuthService.demoPassword,
  );

  bool _isLoading = false;
  final bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  String? _bannerMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearBanner() {
    if (_bannerMessage != null) {
      setState(() => _bannerMessage = null);
    }
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }

    final String? emailError = validateEmail(_emailController.text);
    final String? passwordError = validatePassword(_passwordController.text);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _bannerMessage = null;
    });
    if (emailError != null || passwordError != null) {
      return;
    }

    setState(() => _isLoading = true);
    final AuthController auth = authControllerOf(context);

    try {
      await auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const AppShell(),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _bannerMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _bannerMessage = 'Koneksi gagal. Coba lagi.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.detailPageBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.horizontalPadding,
                vertical: AppDimensions.loginVerticalPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight -
                      AppDimensions.loginVerticalPadding * 2,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppDimensions.loginMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const AppLogoBadge(),
                        const SizedBox(height: AppDimensions.loginLogoToTitle),
                        Text('Selamat datang', style: AppTextStyles.loginTitle),
                        const SizedBox(
                          height: AppDimensions.loginTitleToSubtitle,
                        ),
                        Text(
                          'Masuk untuk meminjam dan mengembalikan aset kantor.',
                          style: AppTextStyles.loginSubtitle,
                          maxLines: 2,
                        ),
                        const SizedBox(
                          height: AppDimensions.loginSubtitleToFields,
                        ),
                        AuthTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          errorText: _emailError,
                          onChanged: (_) => _clearBanner(),
                        ),
                        const SizedBox(height: AppDimensions.loginFieldSpacing),
                        AuthTextField(
                          label: 'Password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          errorText: _passwordError,
                          onChanged: (_) => _clearBanner(),
                        ),
                        if (_bannerMessage != null) ...<Widget>[
                          const SizedBox(
                            height: AppDimensions.loginFieldSpacing,
                          ),
                          ErrorBanner(message: _bannerMessage!),
                        ],
                        const SizedBox(height: AppDimensions.loginFieldSpacing),
                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.detailBorrowButtonHeight,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primary,
                              foregroundColor: AppColors.surface,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.loginFieldRadius,
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: AppDimensions
                                        .loginProgressIndicatorSize,
                                    height: AppDimensions
                                        .loginProgressIndicatorSize,
                                    child: CircularProgressIndicator(
                                      strokeWidth: AppDimensions
                                          .historyProgressStrokeWidth,
                                      color: AppColors.surface,
                                    ),
                                  )
                                : Text(
                                    'Masuk',
                                    style: AppTextStyles.loginButton,
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.loginButtonToNote),
                        Center(
                          child: Text(
                            'Akun demo, bukan untuk produksi.',
                            style: AppTextStyles.loginNote,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
