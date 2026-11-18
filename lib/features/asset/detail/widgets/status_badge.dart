import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/asset_status.dart';

/// Badge status pada halaman detail: pill tanpa dot dengan letter-spacing.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.label});

  final AssetStatus status;

  /// Label opsional (mis. RETURNED). Default mengikuti status aset.
  final String? label;

  ({Color background, Color foreground}) get _colors {
    return switch (status) {
      AssetStatus.available => (
        background: AppColors.detailBadgeAvailableBackground,
        foreground: AppColors.detailBadgeAvailableForeground,
      ),
      AssetStatus.borrowed => (
        background: AppColors.borrowedBackground,
        foreground: AppColors.borrowedForeground,
      ),
      AssetStatus.maintenance => (
        background: AppColors.maintenanceBackground,
        foreground: AppColors.maintenanceForeground,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.badgeHorizontalPadding,
        vertical: AppDimensions.badgeVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      ),
      child: Text(
        label ?? status.name.toUpperCase(),
        style: AppTextStyles.detailBadge.copyWith(color: colors.foreground),
      ),
    );
  }
}
