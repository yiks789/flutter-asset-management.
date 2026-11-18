import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

/// Logo aplikasi pada halaman login.
class AppLogoBadge extends StatelessWidget {
  const AppLogoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.loginLogoSize,
      height: AppDimensions.loginLogoSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.loginLogoRadius),
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        size: AppDimensions.loginLogoIconSize,
        color: AppColors.surface,
      ),
    );
  }
}
