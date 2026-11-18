import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../utils/history_dates.dart';

/// Tampilan ketika tidak ada pinjaman pada tab + bulan terpilih.
class EmptyHistory extends StatelessWidget {
  const EmptyHistory({super.key, required this.tab});

  final HistoryTab tab;

  @override
  Widget build(BuildContext context) {
    final String message = switch (tab) {
      HistoryTab.borrowed => 'Belum ada aset yang sedang dipinjam.',
      HistoryTab.returned => 'Belum ada aset yang dikembalikan.',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.historyCardSpacing * 3,
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.inbox_outlined,
            size: AppDimensions.historyEmptyIconSize,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.historyEmptySpacing),
          Text(message, style: AppTextStyles.historyEmpty),
        ],
      ),
    );
  }
}
