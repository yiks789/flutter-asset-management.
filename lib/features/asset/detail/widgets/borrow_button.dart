import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/asset_status.dart';

/// Tombol "Pinjam Aset" dengan state normal, loading, dan disabled.
class BorrowButton extends StatelessWidget {
  const BorrowButton({
    super.key,
    required this.status,
    required this.isLoading,
    required this.onPressed,
  });

  final AssetStatus status;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = status == AssetStatus.available && !isLoading;
    final Color background = enabled
        ? AppColors.primary
        : AppColors.disabledBackground;
    final Color foreground = enabled
        ? AppColors.surface
        : AppColors.disabledText;

    return SizedBox(
      width: double.infinity,
      height: AppDimensions.detailBorrowButtonHeight,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: background,
          foregroundColor: foreground,
          disabledForegroundColor: foreground,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.detailBorrowButtonRadius,
            ),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: AppDimensions.detailProgressIndicatorSize,
                height: AppDimensions.detailProgressIndicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                ),
              )
            : Text('Pinjam Aset', style: AppTextStyles.detailBorrowButton),
      ),
    );
  }
}
