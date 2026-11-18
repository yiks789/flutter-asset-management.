import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/filter/widgets/active_filter_bar.dart';
import '../../../core/filter/widgets/filter_button.dart';
import '../../../core/pagination/page_delay.dart';
import '../../../core/pagination/pagination_state_mixin.dart';
import '../../../core/pagination/widgets/paginated_footer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../history/pages/history_page.dart'
    show kDefaultHistorySearchDebounce;
import '../data/asset_repository.dart';
import '../data/asset_repository_scope.dart';
import '../detail/pages/asset_detail_page.dart';
import '../models/asset_item.dart';
import '../models/asset_status.dart';
import '../utils/asset_filters.dart';
import '../widgets/asset_card.dart';
import '../widgets/asset_filter_sheet.dart';
import '../widgets/asset_header.dart';
import '../widgets/asset_search_field.dart';

/// Halaman "Daftar Aset" dengan pencarian, filter, dan pagination in-memory.
class AssetListPage extends StatefulWidget {
  const AssetListPage({
    super.key,
    this.pageDelay = kDefaultPageDelay,
    this.searchDebounce = kDefaultHistorySearchDebounce,
  });

  final PageDelay pageDelay;
  final Duration searchDebounce;

  @override
  State<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage>
    with PaginatedStateMixin<AssetListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<int> _filterRevision = ValueNotifier<int>(0);

  String _query = '';
  Set<AssetStatus> _selectedStatuses = <AssetStatus>{};
  String? _selectedCategory;
  late AssetRepository _repository;
  bool _initialized = false;
  Timer? _searchDebounceTimer;

  List<AssetItem> get _filteredAssets => assetsForFilters(
    _repository.assets,
    _selectedStatuses,
    _selectedCategory,
    _query,
  );

  List<String> get _availableCategories =>
      categoriesForAssets(_repository.assets);

  int get _badgeCount =>
      assetActiveFilterCount(_selectedStatuses, _selectedCategory);

  bool get _hasActiveFilters => _badgeCount > 0;

  @override
  int get paginatedTotal => _filteredAssets.length;

  @override
  PageDelay get pageDelay => widget.pageDelay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _repository = assetRepositoryOf(context);
    _repository.addListener(_handleRepositoryChanged);
    _initialized = true;
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _filterRevision.dispose();
    if (_initialized) {
      _repository.removeListener(_handleRepositoryChanged);
    }
    _searchController.dispose();
    super.dispose();
  }

  void _notifyFilterRevision() {
    _filterRevision.value++;
  }

  bool _sameFilters(Set<AssetStatus> statuses, String? category) {
    if (category != _selectedCategory ||
        statuses.length != _selectedStatuses.length) {
      return false;
    }
    return statuses.every(_selectedStatuses.contains);
  }

  void _handleRepositoryChanged() {
    if (!mounted) {
      return;
    }
    bool filtersChanged = false;
    bool shouldJump = false;
    setState(() {
      final String? category = normalizeSelectedAssetCategory(
        _availableCategories,
        _selectedCategory,
      );
      final Set<AssetStatus> statuses =
          normalizeSelectedStatuses(_selectedStatuses);
      if (!_sameFilters(statuses, category)) {
        _selectedStatuses = statuses;
        _selectedCategory = category;
        resetPaginationState();
        shouldJump = true;
        filtersChanged = true;
      } else {
        clampPaginationState();
      }
    });
    if (filtersChanged) {
      _notifyFilterRevision();
    }
    if (shouldJump) {
      jumpPaginationToTop();
    }
    scheduleCheckForMore();
  }

  void _applyFilters(Set<AssetStatus> statuses, String? category) {
    final Set<AssetStatus> nextStatuses = normalizeSelectedStatuses(statuses);
    final String? nextCategory = normalizeSelectedAssetCategory(
      _availableCategories,
      category,
    );
    if (_sameFilters(nextStatuses, nextCategory)) {
      return;
    }
    setState(() {
      _selectedStatuses = Set<AssetStatus>.from(nextStatuses);
      _selectedCategory = nextCategory;
    });
    _notifyFilterRevision();
    resetPagination();
  }

  void _handleSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(widget.searchDebounce, () {
      if (!mounted) {
        return;
      }
      final String normalized = value.trim().toLowerCase();
      if (normalized == _query) {
        return;
      }
      setState(() => _query = normalized);
      resetPagination();
    });
  }

  Future<void> _openFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.filterSheetTopRadius),
        ),
      ),
      builder: (BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: _filterRevision,
        builder: (BuildContext context, int _, Widget? __) {
          return AssetFilterSheet(
            repository: _repository,
            selectedStatuses: _selectedStatuses,
            selectedCategory: _selectedCategory,
            onChanged: _applyFilters,
          );
        },
      ),
    );
  }

  void _removeStatus(AssetStatus status) {
    final Set<AssetStatus> statuses = Set<AssetStatus>.from(_selectedStatuses)
      ..remove(status);
    _applyFilters(statuses, _selectedCategory);
  }

  void _removeCategory() => _applyFilters(_selectedStatuses, null);

  Future<void> _openDetail(AssetItem asset) async {
    // Route baru bukan descendant scope, jadi repository dikirim eksplisit.
    await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) =>
            AssetDetailPage(asset: asset, repository: _repository),
      ),
    );
  }

  List<ActiveFilterBarItem> _activeFilterItems() {
    final List<ActiveFilterBarItem> items = <ActiveFilterBarItem>[];
    for (final AssetStatus status in kAssetStatusDisplayOrder) {
      if (_selectedStatuses.contains(status)) {
        items.add(
          ActiveFilterBarItem(
            label: assetStatusLabel(status),
            onRemove: () => _removeStatus(status),
          ),
        );
      }
    }
    if (_selectedCategory != null) {
      items.add(
        ActiveFilterBarItem(
          label: _selectedCategory!,
          onRemove: _removeCategory,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final List<AssetItem> assets = _filteredAssets;
    final int shown = visibleCount;
    final bool loading = isPageLoading;
    scheduleCheckForMore();

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AssetHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.horizontalPadding,
                AppDimensions.searchTopSpacing,
                AppDimensions.horizontalPadding,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: AssetSearchField(
                      controller: _searchController,
                      onChanged: _handleSearchChanged,
                    ),
                  ),
                  const SizedBox(
                    width: AppDimensions.historyFilterButtonSpacing,
                  ),
                  FilterButton(
                    badgeCount: _badgeCount,
                    onTap: _openFilterSheet,
                  ),
                ],
              ),
            ),
            if (_hasActiveFilters)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppDimensions.horizontalPadding,
                  right: AppDimensions.horizontalPadding,
                  top: AppDimensions.historyActiveChipsSpacing,
                ),
                child: ActiveFilterBar(items: _activeFilterItems()),
              ),
            Expanded(
              child: assets.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.horizontalPadding,
                        vertical: AppDimensions.historyCardSpacing * 3,
                      ),
                      child: Center(
                        child: Text(
                          'Tidak ada aset yang cocok dengan filter.',
                          style: AppTextStyles.historyEmpty,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: paginationController,
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.horizontalPadding,
                        AppDimensions.listTopSpacing,
                        AppDimensions.horizontalPadding,
                        AppDimensions.listBottomSpacing,
                      ),
                      itemCount: shown + (loading ? 1 : 0),
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: AppDimensions.cardSpacing),
                      itemBuilder: (BuildContext context, int index) {
                        if (index >= shown) {
                          return const PaginatedFooter(isLoading: true);
                        }
                        return AssetCard(
                          asset: assets[index],
                          onTap: () => _openDetail(assets[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
