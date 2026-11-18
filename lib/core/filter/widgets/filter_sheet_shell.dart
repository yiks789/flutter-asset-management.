import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// Kerangka bottom sheet filter: handle, header, konten, dan helper.
class FilterSheetShell extends StatelessWidget {
  const FilterSheetShell({
    super.key,
    required this.title,
    required this.onClose,
    required this.children,
    this.helperText,
  });

  final String title;
  final VoidCallback onClose;
  final List<Widget> children;
  final String? helperText;

  static Widget sheetPadded(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.filterSheetPadding,
      ),
      child: child,
    );
  }

  static Widget sectionHeader({required String title, required String hint}) {
    return sheetPadded(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(title, style: AppTextStyles.filterSheetSectionTitle),
          ),
          const SizedBox(width: AppDimensions.chipSpacing),
          Flexible(
            child: Text(
              hint,
              style: AppTextStyles.filterSheetHint,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppDimensions.filterSheetPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                sheetPadded(
                  Center(
                    child: Container(
                      width: AppDimensions.filterSheetHandleWidth,
                      height: AppDimensions.filterSheetHandleHeight,
                      decoration: BoxDecoration(
                        color: AppColors.historyTabBackground,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.pillRadius,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.filterSheetHeaderSpacing),
                sheetPadded(
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(title, style: AppTextStyles.filterSheetTitle),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.detailTextPrimary,
                        ),
                        onPressed: onClose,
                        tooltip: 'Tutup',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.filterSheetSectionSpacing),
                ...children,
                if (helperText != null) ...<Widget>[
                  const SizedBox(height: AppDimensions.filterSheetSectionSpacing),
                  sheetPadded(
                    Text(helperText!, style: AppTextStyles.filterSheetHint),
                  ),
                ],
                const SizedBox(height: AppDimensions.filterSheetBottomPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
