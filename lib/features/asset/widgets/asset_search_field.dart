import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Kolom pencarian nama/kode aset. Nilainya dikendalikan oleh halaman.
class AssetSearchField extends StatelessWidget {
  const AssetSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.searchRadius),
      borderSide: const BorderSide(
        color: AppColors.filterFieldBorder,
        width: AppDimensions.chipBorderWidth,
      ),
    );

    return SizedBox(
      height: AppDimensions.searchHeight,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.searchInput,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          hintText: 'Cari nama atau kode aset',
          hintStyle: AppTextStyles.searchHint,
          prefixIcon: const Icon(
            Icons.search_outlined,
            size: AppDimensions.searchIconSize,
            color: AppColors.textSecondary,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth:
                AppDimensions.searchHeight - AppDimensions.horizontalPadding,
            maxHeight: AppDimensions.searchHeight,
          ),
          contentPadding: EdgeInsets.zero,
          border: border,
          enabledBorder: border,
          focusedBorder: border,
        ),
      ),
    );
  }
}
