import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Tombol Kembalikan dengan indikator loading saat request berjalan.
class ReturnButton extends StatelessWidget {
  const ReturnButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.historyReturnButtonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.historyReturnButtonRadius,
            ),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: AppDimensions.historyProgressIndicatorSize,
                height: AppDimensions.historyProgressIndicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: AppDimensions.historyProgressStrokeWidth,
                  color: AppColors.surface,
                ),
              )
            : Text('Kembalikan', style: AppTextStyles.historyReturnButton),
      ),
    );
  }
}
