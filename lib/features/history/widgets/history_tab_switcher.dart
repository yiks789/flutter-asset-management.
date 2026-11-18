import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../utils/history_dates.dart';

/// Switcher kustom untuk memilih tab Dipinjam / Dikembalikan.
class HistoryTabSwitcher extends StatelessWidget {
  const HistoryTabSwitcher({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final HistoryTab selected;
  final ValueChanged<HistoryTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.historyTabHeight,
      padding: const EdgeInsets.all(AppDimensions.historyTabPadding),
      decoration: BoxDecoration(
        color: AppColors.historyTabBackground,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _TabOption(
              label: 'Dipinjam',
              active: selected == HistoryTab.borrowed,
              onTap: () => onChanged(HistoryTab.borrowed),
            ),
          ),
          Expanded(
            child: _TabOption(
              label: 'Dikembalikan',
              active: selected == HistoryTab.returned,
              onTap: () => onChanged(HistoryTab.returned),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabOption extends StatelessWidget {
  const _TabOption({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
        ),
        child: Text(
          label,
          style: active
              ? AppTextStyles.historyTabActive
              : AppTextStyles.historyTabInactive,
        ),
      ),
    );
  }
}
