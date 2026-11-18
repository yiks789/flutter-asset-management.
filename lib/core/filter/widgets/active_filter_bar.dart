import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';
import 'active_filter_chip.dart';

/// Baris chip filter aktif yang bisa digeser horizontal.
class ActiveFilterBar extends StatelessWidget {
  const ActiveFilterBar({super.key, required this.items});

  final List<ActiveFilterBarItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.historyActiveChipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: AppDimensions.chipSpacing),
        itemBuilder: (BuildContext context, int index) {
          final ActiveFilterBarItem item = items[index];
          return ActiveFilterChip(label: item.label, onRemove: item.onRemove);
        },
      ),
    );
  }
}

class ActiveFilterBarItem {
  const ActiveFilterBarItem({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;
}
