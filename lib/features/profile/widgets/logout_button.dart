import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Tombol Keluar dengan outline merah tua, tanpa elevation.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.detailBorrowButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.errorIcon,
          side: const BorderSide(
            color: AppColors.errorIcon,
            width: AppDimensions.chipBorderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.searchRadius),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.logout, size: AppDimensions.navIconSize),
            const SizedBox(width: AppDimensions.profileLogoutIconSpacing),
            Text('Keluar', style: AppTextStyles.logoutButton),
          ],
        ),
      ),
    );
  }
}
