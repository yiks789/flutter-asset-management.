import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../asset/data/asset_repository.dart';
import '../../asset/data/asset_repository_scope.dart';
import '../../auth/data/auth_controller.dart';
import '../../auth/data/auth_scope.dart';
import '../../auth/data/auth_user.dart';
import '../../auth/pages/login_page.dart';
import '../utils/profile_stats.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/stat_card.dart';

/// Halaman Profil dengan data sesi dan statistik dari repository.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) {
    final AuthController auth = authControllerOf(context);
    final NavigatorState navigator = Navigator.of(context);

    auth.signOut();
    navigator.pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const LoginPage(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController auth = authControllerOf(context);
    final AssetRepository repository = assetRepositoryOf(context);
    final AuthUser? user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.detailPageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.horizontalPadding,
                  AppDimensions.historyTopPadding,
                  AppDimensions.horizontalPadding,
                  AppDimensions.historyBottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Profil', style: AppTextStyles.historyTitle),
                    const SizedBox(height: AppDimensions.profileSectionSpacing),
                    if (user != null)
                      ProfileHeaderCard(name: user.name, email: user.email)
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: AppDimensions.profileSectionSpacing),
                    ListenableBuilder(
                      listenable: repository,
                      builder: (BuildContext context, Widget? child) {
                        final ({int borrowed, int returned}) stats =
                            profileStats(repository.loans);
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: StatCard(
                                label: 'Sedang dipinjam',
                                value: stats.borrowed,
                                valueStyle:
                                    AppTextStyles.profileStatValueBorrowed,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.profileStatGap),
                            Expanded(
                              child: StatCard(
                                label: 'Dikembalikan',
                                value: stats.returned,
                                valueStyle:
                                    AppTextStyles.profileStatValueReturned,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.profileSectionSpacing),
                    if (user != null)
                      ProfileInfoCard(
                        name: user.name,
                        email: user.email,
                        division: user.division,
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.horizontalPadding,
                AppDimensions.profileLogoutTopPadding,
                AppDimensions.horizontalPadding,
                AppDimensions.profileLogoutBottomPadding,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: AppColors.cardBorder,
                    width: AppDimensions.navBorderWidth,
                  ),
                ),
              ),
              child: LogoutButton(onPressed: () => _logout(context)),
            ),
          ],
        ),
      ),
    );
  }
}
