import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// Tombol pembuka bottom sheet filter, dengan badge jumlah chip aktif.
class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.badgeCount,
    required this.onTap,
  });

  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasFilters = badgeCount > 0;

    return SizedBox(
      width: AppDimensions.historyFilterButtonSize,
      height: AppDimensions.historyFilterButtonSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: hasFilters
                      ? AppColors.primary
                      : AppColors.filterFieldBorder,
                  width: AppDimensions.chipBorderWidth,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.searchRadius,
                  ),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(
                Icons.tune,
                size: AppDimensions.searchIconSize,
                color: AppColors.primary,
              ),
            ),
          ),
          if (hasFilters)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: AppDimensions.historyFilterBadgeSize,
                height: AppDimensions.historyFilterBadgeSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.filterBadgeBackground,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: AppTextStyles.historyFilterBadge,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
