import 'package:flutter/material.dart';

import '../../../core/filter/widgets/filter_sheet_shell.dart';
import '../../../core/filter/widgets/selectable_chip.dart';
import '../../../core/filter/widgets/two_row_chip_scroll.dart';
import '../../../core/theme/app_dimensions.dart';
import '../data/asset_repository.dart';
import '../models/asset_status.dart';
import '../utils/asset_filters.dart';

/// Bottom sheet "Filter Aset". Setiap perubahan langsung diterapkan.
class AssetFilterSheet extends StatelessWidget {
  const AssetFilterSheet({
    super.key,
    required this.repository,
    required this.selectedStatuses,
    required this.selectedCategory,
    required this.onChanged,
  });

  final AssetRepository repository;
  final Set<AssetStatus> selectedStatuses;
  final String? selectedCategory;
  final void Function(Set<AssetStatus> statuses, String? category) onChanged;

  void _toggleStatus(AssetStatus status) {
    final Set<AssetStatus> next = Set<AssetStatus>.from(selectedStatuses);
    if (next.contains(status)) {
      next.remove(status);
    } else {
      next.add(status);
    }
    onChanged(next, selectedCategory);
  }

  void _selectCategory(String? category) {
    onChanged(Set<AssetStatus>.from(selectedStatuses), category);
  }

  int? _firstSelectedStatusIndex(Set<AssetStatus> selected) {
    for (int index = 0; index < kAssetStatusDisplayOrder.length; index++) {
      if (selected.contains(kAssetStatusDisplayOrder[index])) {
        return index;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (BuildContext context, Widget? child) {
        final List<String> categories = categoriesForAssets(repository.assets);
        final Set<AssetStatus> effectiveStatuses =
            normalizeSelectedStatuses(selectedStatuses);
        final String? effectiveCategory = normalizeSelectedAssetCategory(
          categories,
          selectedCategory,
        );

        final int? statusFocusIndex = _firstSelectedStatusIndex(
          effectiveStatuses,
        );
        final int categoryIndex = effectiveCategory == null
            ? -1
            : categories.indexOf(effectiveCategory);
        final int? categoryFocusIndex = effectiveCategory == null
            ? 0
            : (categoryIndex < 0 ? null : categoryIndex + 1);

        return FilterSheetShell(
          title: 'Filter Aset',
          onClose: () => Navigator.of(context).pop(),
          helperText: 'Kosongkan pilihan untuk menampilkan semua status.',
          children: <Widget>[
            FilterSheetShell.sectionHeader(
              title: 'Status',
              hint: 'Pilih lebih dari satu',
            ),
            const SizedBox(height: AppDimensions.filterSheetSectionToChips),
            TwoRowChipScroll(
              initialFocusIndex: statusFocusIndex,
              children: <Widget>[
                for (final AssetStatus status in kAssetStatusDisplayOrder)
                  SelectableChip(
                    label: assetStatusLabel(status),
                    selected: effectiveStatuses.contains(status),
                    variant: SelectableChipVariant.checkbox,
                    onTap: () => _toggleStatus(status),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.filterSheetSectionSpacing),
            FilterSheetShell.sectionHeader(
              title: 'Kategori',
              hint: 'Pilih satu',
            ),
            const SizedBox(height: AppDimensions.filterSheetSectionToChips),
            TwoRowChipScroll(
              initialFocusIndex: categoryFocusIndex,
              children: <Widget>[
                SelectableChip(
                  label: 'Semua',
                  selected: effectiveCategory == null,
                  variant: SelectableChipVariant.radio,
                  onTap: () => _selectCategory(null),
                ),
                for (final String category in categories)
                  SelectableChip(
                    label: category,
                    selected: effectiveCategory == category,
                    variant: SelectableChipVariant.radio,
                    onTap: () => _selectCategory(category),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
