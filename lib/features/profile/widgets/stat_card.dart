import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Kartu statistik kecil: label di atas, angka besar di bawah.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.valueStyle,
  });

  final String label;
  final int value;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: AppDimensions.profileStatCardMinHeight,
      ),
      padding: const EdgeInsets.all(AppDimensions.profileStatCardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.profileStatCardRadius,
        ),
        border: Border.all(
          color: AppColors.detailInfoBorder,
          width: AppDimensions.chipBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTextStyles.profileStatLabel),
          const SizedBox(height: AppDimensions.profileStatLabelToValue),
          Text('$value', style: valueStyle),
        ],
      ),
    );
  }
}
