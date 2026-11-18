import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/clock/app_clock.dart';
import '../../../core/pagination/page_delay.dart';
import '../../../core/pagination/pagination_state_mixin.dart';
import '../../../core/pagination/widgets/paginated_footer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../asset/data/asset_repository.dart';
import '../../asset/data/asset_repository_scope.dart';
import '../../asset/data/asset_return_service.dart';
import '../../asset/detail/widgets/error_banner.dart';
import '../../asset/models/loan_item.dart';
import '../models/month_key.dart';
import '../utils/history_dates.dart';
import '../widgets/active_filter_chips.dart';
import '../widgets/empty_history.dart';
import '../widgets/filter_button.dart';
import '../widgets/history_filter_empty.dart';
import '../widgets/history_filter_sheet.dart';
import '../widgets/history_search_field.dart';
import '../widgets/history_tab_switcher.dart';
import '../widgets/loan_card.dart';

/// Ubah menjadi true untuk mencoba ErrorBanner pengembalian di aplikasi.
const bool kSimulateReturnErrorOnDemo = false;

/// Jeda debounce bawaan pencarian Riwayat; bisa disuntikkan pada test.
const Duration kDefaultHistorySearchDebounce = Duration(milliseconds: 300);

/// Halaman "Riwayat Saya" dengan tab, pencarian, filterbottom sheet,
/// chip aktif, dan pagination in-memory.
class HistoryPage extends StatefulWidget {
  const HistoryPage({
    super.key,
    this.returnService,
    this.clock,
    this.pageDelay = kDefaultPageDelay,
    this.searchDebounce = kDefaultHistorySearchDebounce,
  });

  final AssetReturnService? returnService;
  final AppClock? clock;
  final PageDelay pageDelay;
  final Duration searchDebounce;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with PaginatedStateMixin<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<int> _filterRevision = ValueNotifier<int>(0);

  late final AssetReturnService _service =
      widget.returnService ??
      const StubAssetReturnService(
        simulateReturnError: kSimulateReturnErrorOnDemo,
      );

  late AssetRepository _repository;
  late AppClock _clock;
  bool _initialized = false;

  HistoryTab _tab = HistoryTab.borrowed;
  Set<MonthKey> _selectedMonths = <MonthKey>{};
  String? _selectedCategory; // null = "Semua".
  String _query = ''; // Sudah di-trim dan lowercase.
  Timer? _searchDebounceTimer;
  String? _errorMessage;
  String? _returningCode;

  String Function(LoanItem) get _categoryOf =>
      (LoanItem loan) =>
          _repository.assetByCode(loan.assetCode)?.category ?? '';

  List<MonthKey> get _availableMonths => monthsForTab(_repository.loans, _tab);

  List<String> get _availableCategories =>
      categoriesForTab(_repository.loans, _tab, _categoryOf);

  List<LoanItem> get _filteredLoans => loansForFilters(
    _repository.loans,
    _tab,
    _selectedMonths,
    _selectedCategory,
    _query,
    _categoryOf,
  );

  bool get _hasActiveFilters =>
      activeFilterCount(_selectedMonths, _selectedCategory) > 0;

  @override
  int get paginatedTotal => _filteredLoans.length;

  @override
  PageDelay get pageDelay => widget.pageDelay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    _repository = assetRepositoryOf(context);
    _clock = widget.clock ?? _repository.clock;
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

  bool _sameFilters(Set<MonthKey> months, String? category) {
    if (category != _selectedCategory ||
        months.length != _selectedMonths.length) {
      return false;
    }
    return months.every(_selectedMonths.contains);
  }

  void _handleRepositoryChanged() {
    if (!mounted) {
      return;
    }

    bool filtersChanged = false;
    bool shouldJump = false;
    setState(() {
      final Set<MonthKey> months = normalizeSelectedMonths(
        _availableMonths,
        _selectedMonths,
      );
      final String? category = normalizeSelectedCategory(
        _availableCategories,
        _selectedCategory,
      );
      if (!_sameFilters(months, category)) {
        _selectedMonths = months;
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

  void _applyFilters(Set<MonthKey> months, String? category) {
    if (_sameFilters(months, category)) {
      return;
    }
    setState(() {
      _selectedMonths = Set<MonthKey>.from(months);
      _selectedCategory = category;
      _errorMessage = null;
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
      setState(() {
        _query = normalized;
        _errorMessage = null;
      });
      resetPagination();
    });
  }

  void _clearSearch() {
    _searchDebounceTimer?.cancel();
    _searchController.clear();
    if (_query.isEmpty) {
      return;
    }
    setState(() {
      _query = '';
      _errorMessage = null;
    });
    resetPagination();
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
          return HistoryFilterSheet(
            tab: _tab,
            repository: _repository,
            selectedMonths: _selectedMonths,
            selectedCategory: _selectedCategory,
            onChanged: _applyFilters,
          );
        },
      ),
    );
  }

  void _changeTab(HistoryTab tab) {
    if (tab == _tab) {
      return;
    }
    setState(() {
      _tab = tab;
      _selectedMonths = <MonthKey>{};
      _selectedCategory = null;
      _errorMessage = null;
    });
    _notifyFilterRevision();
    resetPagination();
  }

  void _removeMonth(MonthKey month) {
    final Set<MonthKey> months = Set<MonthKey>.from(_selectedMonths)
      ..remove(month);
    _applyFilters(months, _selectedCategory);
  }

  void _removeCategory() => _applyFilters(_selectedMonths, null);

  Future<void> _returnAsset(LoanItem loan) async {
    if (_returningCode != null) {
      return;
    }

    setState(() {
      _returningCode = loan.assetCode;
      _errorMessage = null;
    });

    try {
      await _service.returnAsset(loan.assetCode);
      if (!mounted) {
        return;
      }

      // Listener repository melakukan rekonsiliasi filter dan pagination.
      // Halaman sengaja tetap di tab saat ini dan filter tidak dikosongkan.
      _repository.returnAsset(loan.assetCode, now: _clock.now());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aset berhasil dikembalikan')),
      );
      setState(() => _returningCode = null);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _returningCode = null;
        _errorMessage =
            'Koneksi gagal. Pengembalian belum tercatat. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<LoanItem> filteredLoans = _filteredLoans;
    final List<LoanItem> pagedLoans = filteredLoans
        .take(currentPageWindow.visibleCount)
        .toList(growable: false);
    final List<MonthKey> activeMonths = _selectedMonths.toList()..sort();
    scheduleCheckForMore();

    return Scaffold(
      backgroundColor: AppColors.detailPageBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          controller: paginationController,
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.horizontalPadding,
            AppDimensions.historyTopPadding,
            AppDimensions.horizontalPadding,
            AppDimensions.historyBottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Riwayat Saya', style: AppTextStyles.historyTitle),
              const SizedBox(height: AppDimensions.historyTitleToTabs),
              HistoryTabSwitcher(selected: _tab, onChanged: _changeTab),
              const SizedBox(height: AppDimensions.historyTabsToFilter),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: HistorySearchField(
                      controller: _searchController,
                      onChanged: _handleSearchChanged,
                      onClear: _clearSearch,
                    ),
                  ),
                  const SizedBox(
                    width: AppDimensions.historyFilterButtonSpacing,
                  ),
                  FilterButton(
                    badgeCount: activeFilterCount(
                      _selectedMonths,
                      _selectedCategory,
                    ),
                    onTap: _openFilterSheet,
                  ),
                ],
              ),
              if (_hasActiveFilters) ...<Widget>[
                const SizedBox(height: AppDimensions.historyActiveChipsSpacing),
                ActiveFilterChips(
                  months: activeMonths,
                  category: _selectedCategory,
                  onRemoveMonth: _removeMonth,
                  onRemoveCategory: _removeCategory,
                ),
              ],
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: AppDimensions.historyFilterToSummary),
                ErrorBanner(message: _errorMessage!),
              ],
              const SizedBox(height: AppDimensions.historyFilterToSummary),
              Text(
                summaryText(_tab, filteredLoans.length),
                style: AppTextStyles.historySummary,
              ),
              const SizedBox(height: AppDimensions.historySummaryToList),
              if (filteredLoans.isEmpty)
                _hasActiveFilters || _query.isNotEmpty
                    ? const HistoryFilterEmpty()
                    : EmptyHistory(tab: _tab)
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final LoanItem loan in pagedLoans) ...<Widget>[
                      LoanCard(
                        loan: loan,
                        isReturning: _returningCode == loan.assetCode,
                        onReturn: () => _returnAsset(loan),
                      ),
                      const SizedBox(height: AppDimensions.historyCardSpacing),
                    ],
                    PaginatedFooter(isLoading: isPageLoading),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
