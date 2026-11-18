import 'package:flutter/material.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Empty state khusus saat hasil kosong karena filter/pencarian.
class HistoryFilterEmpty extends StatelessWidget {
  const HistoryFilterEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.historyCardSpacing * 3,
      ),
      child: Center(
        child: Text(
          'Tidak ada aset yang cocok dengan filter.',
          style: AppTextStyles.historyEmpty,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
