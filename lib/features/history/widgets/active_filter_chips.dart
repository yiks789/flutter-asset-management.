import 'package:flutter/material.dart';

import '../../../core/filter/widgets/active_filter_bar.dart';
import '../models/month_key.dart';
import '../utils/history_dates.dart';

export '../../../core/filter/widgets/active_filter_chip.dart';

/// Baris chip filter yang sedang aktif. Bulan diurutkan terbaru → terlama,
/// diikuti kategori bila ada. Ketuk × menghapus filter itu saja.
class ActiveFilterChips extends StatelessWidget {
  const ActiveFilterChips({
    super.key,
    required this.months,
    required this.category,
    required this.onRemoveMonth,
    required this.onRemoveCategory,
  });

  final List<MonthKey> months;
  final String? category;
  final ValueChanged<MonthKey> onRemoveMonth;
  final VoidCallback onRemoveCategory;

  @override
  Widget build(BuildContext context) {
    return ActiveFilterBar(
      items: <ActiveFilterBarItem>[
        for (final MonthKey month in months)
          ActiveFilterBarItem(
            label: monthLabel(month),
            onRemove: () => onRemoveMonth(month),
          ),
        if (category != null)
          ActiveFilterBarItem(
            label: category!,
            onRemove: onRemoveCategory,
          ),
      ],
    );
  }
}

