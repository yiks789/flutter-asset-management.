import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/asset_status.dart';

/// Badge status berbentuk pill dengan titik dan teks kapital.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final AssetStatus status;

  ({Color background, Color foreground, String label}) get _style {
    return switch (status) {
      AssetStatus.available => (
        background: AppColors.availableBackground,
        foreground: AppColors.availableForeground,
        label: 'AVAILABLE',
      ),
      AssetStatus.borrowed => (
        background: AppColors.borrowedBackground,
        foreground: AppColors.borrowedForeground,
        label: 'BORROWED',
      ),
      AssetStatus.maintenance => (
        background: AppColors.maintenanceBackground,
        foreground: AppColors.maintenanceForeground,
        label: 'MAINTENANCE',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.badgeHorizontalPadding,
        vertical: AppDimensions.badgeVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: AppDimensions.badgeDotSize,
            height: AppDimensions.badgeDotSize,
            decoration: BoxDecoration(
              color: style.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.badgeDotSpacing),
          Text(
            style.label,
            style: AppTextStyles.badge.copyWith(color: style.foreground),
          ),
        ],
      ),
    );
  }
}
