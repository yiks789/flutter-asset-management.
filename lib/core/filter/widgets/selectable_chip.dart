import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

enum SelectableChipVariant { checkbox, radio }

/// Chip pilihan di bottom sheet: checkbox atau radio.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.variant,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final SelectableChipVariant variant;
  final VoidCallback onTap;

  IconData get _icon => switch (variant) {
    SelectableChipVariant.checkbox =>
      selected ? Icons.check_box : Icons.check_box_outline_blank,
    SelectableChipVariant.radio =>
      selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
  };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      child: Container(
        height: AppDimensions.filterSheetChipHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.historyActiveChipHorizontalPadding,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.filterFieldBorder,
            width: AppDimensions.chipBorderWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              _icon,
              size: AppDimensions.filterSheetChipIconSize,
              color: selected ? AppColors.surface : AppColors.primary,
            ),
            const SizedBox(width: AppDimensions.historyActiveChipTextSpacing),
            Text(
              label,
              style: selected
                  ? AppTextStyles.filterChipSelected
                  : AppTextStyles.filterChipUnselected,
            ),
          ],
        ),
      ),
    );
  }
}
