import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Banner merah muda yang muncul hanya saat ada pesan error.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.detailErrorPadding),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(AppDimensions.detailErrorRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: AppDimensions.detailErrorIconSize,
            color: AppColors.errorIcon,
          ),
          const SizedBox(width: AppDimensions.detailErrorIconSpacing),
          Expanded(child: Text(message, style: AppTextStyles.detailErrorText)),
        ],
      ),
    );
  }
}
