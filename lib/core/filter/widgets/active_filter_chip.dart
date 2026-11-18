import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// Chip filter aktif yang bisa dihapus dengan mengetuk area chip/x.
class ActiveFilterChip extends StatelessWidget {
  const ActiveFilterChip({
    super.key,
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onRemove,
      borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      child: Container(
        height: AppDimensions.historyActiveChipHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.historyActiveChipHorizontalPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.filterActiveChipBackground,
          borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
          border: Border.all(
            color: AppColors.historyCardBorder,
            width: AppDimensions.chipBorderWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(label, style: AppTextStyles.historyActiveFilterChip),
            const SizedBox(width: AppDimensions.historyActiveChipTextSpacing),
            const Icon(
              Icons.close,
              size: AppDimensions.historyActiveChipIconSize,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
