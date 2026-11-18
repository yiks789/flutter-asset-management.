import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Kolom pencarian Riwayat. Gaya mengikuti `AssetSearchField`, dengan ikon
/// hapus yang muncul saat ada teks. Nilai tetap dikendalikan halaman.
class HistorySearchField extends StatefulWidget {
  const HistorySearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<HistorySearchField> createState() => _HistorySearchFieldState();
}

class _HistorySearchFieldState extends State<HistorySearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant HistorySearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

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
        controller: widget.controller,
        onChanged: widget.onChanged,
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
          suffixIcon: widget.controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: AppDimensions.historyActiveChipIconSize,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: widget.onClear,
                  tooltip: 'Hapus pencarian',
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
