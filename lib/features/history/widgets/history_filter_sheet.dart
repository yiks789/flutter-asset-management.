import 'package:flutter/material.dart';

import '../../../core/filter/widgets/filter_sheet_shell.dart';
import '../../../core/filter/widgets/two_row_chip_scroll.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../asset/data/asset_repository.dart';
import '../../asset/models/loan_item.dart';
import '../models/month_key.dart';
import '../utils/history_dates.dart';
import 'selectable_chip.dart';

/// Bottom sheet "Filter Riwayat". Setiap perubahan langsung diterapkan.
class HistoryFilterSheet extends StatelessWidget {
  const HistoryFilterSheet({
    super.key,
    required this.tab,
    required this.repository,
    required this.selectedMonths,
    required this.selectedCategory,
    required this.onChanged,
  });

  final HistoryTab tab;
  final AssetRepository repository;
  final Set<MonthKey> selectedMonths;
  final String? selectedCategory;
  final void Function(Set<MonthKey> months, String? category) onChanged;

  String Function(LoanItem) _categoryOf() => (LoanItem loan) =>
      repository.assetByCode(loan.assetCode)?.category ?? '';

  void _toggleMonth(List<MonthKey> months, MonthKey month) {
    final Set<MonthKey> next = Set<MonthKey>.from(selectedMonths);
    if (next.contains(month)) {
      next.remove(month);
    } else {
      next.add(month);
    }
    onChanged(normalizeSelectedMonths(months, next), selectedCategory);
  }

  void _selectCategory(String? category) {
    onChanged(Set<MonthKey>.from(selectedMonths), category);
  }

  int? _firstSelectedMonthIndex(List<MonthKey> months, Set<MonthKey> selected) {
    for (int index = 0; index < months.length; index++) {
      if (selected.contains(months[index])) {
        return index;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String monthSectionTitle = switch (tab) {
      HistoryTab.borrowed => 'Bulan pinjam',
      HistoryTab.returned => 'Bulan kembali',
    };

    return AnimatedBuilder(
      animation: repository,
      builder: (BuildContext context, Widget? child) {
        final String Function(LoanItem) categoryOf = _categoryOf();
        final List<MonthKey> months = monthsForTab(repository.loans, tab);
        final List<String> categories = categoriesForTab(
          repository.loans,
          tab,
          categoryOf,
        );
        final Set<MonthKey> effectiveMonths = normalizeSelectedMonths(
          months,
          selectedMonths,
        );
        final String? effectiveCategory = normalizeSelectedCategory(
          categories,
          selectedCategory,
        );

        final int? monthFocusIndex = _firstSelectedMonthIndex(
          months,
          effectiveMonths,
        );
        final int categoryIndex = effectiveCategory == null
            ? -1
            : categories.indexOf(effectiveCategory);
        final int? categoryFocusIndex = effectiveCategory == null
            ? 0
            : (categoryIndex < 0 ? null : categoryIndex + 1);

        return FilterSheetShell(
          title: 'Filter Riwayat',
          onClose: () => Navigator.of(context).pop(),
          helperText: 'Kosongkan pilihan untuk menampilkan semua bulan.',
          children: <Widget>[
            FilterSheetShell.sectionHeader(
              title: monthSectionTitle,
              hint: 'Pilih lebih dari satu',
            ),
            const SizedBox(height: AppDimensions.filterSheetSectionToChips),
            TwoRowChipScroll(
              initialFocusIndex: monthFocusIndex,
              children: <Widget>[
                for (final MonthKey month in months)
                  SelectableChip(
                    label: monthLabel(month),
                    selected: effectiveMonths.contains(month),
                    variant: SelectableChipVariant.checkbox,
                    onTap: () => _toggleMonth(months, month),
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

