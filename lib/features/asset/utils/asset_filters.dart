import '../models/asset_item.dart';
import '../models/asset_status.dart';
import '../../../core/filter/filter_utils.dart' as filter_utils;

/// Label Indonesia untuk status aset pada filter/chip aktif.
String assetStatusLabel(AssetStatus status) => switch (status) {
  AssetStatus.available => 'Tersedia',
  AssetStatus.borrowed => 'Dipinjam',
  AssetStatus.maintenance => 'Maintenance',
};

/// Urutan tampilan chip status yang konsisten.
const List<AssetStatus> kAssetStatusDisplayOrder = <AssetStatus>[
  AssetStatus.available,
  AssetStatus.borrowed,
  AssetStatus.maintenance,
];

/// Kategori unik dari seluruh aset, trim, non-kosong, urut abjad.
List<String> categoriesForAssets(List<AssetItem> assets) {
  final Set<String> categories = <String>{};
  for (final AssetItem asset in assets) {
    final String category = asset.category.trim();
    if (category.isNotEmpty) {
      categories.add(category);
    }
  }
  final List<String> result = categories.toList();
  result.sort();
  return result;
}

/// Saring aset: OR di dalam status, AND antar status/kategori/pencarian.
/// Status kosong = semua status. Kategori null = "Semua".
List<AssetItem> assetsForFilters(
  List<AssetItem> assets,
  Set<AssetStatus> statuses,
  String? category,
  String query,
) {
  final String keyword = query.trim().toLowerCase();
  final String? selectedCategory = category?.trim();
  final bool hasCategory =
      selectedCategory != null && selectedCategory.isNotEmpty;

  return assets
      .where((AssetItem asset) {
        final bool matchesStatus =
            statuses.isEmpty || statuses.contains(asset.status);
        if (!matchesStatus) {
          return false;
        }

        if (hasCategory && asset.category.trim() != selectedCategory) {
          return false;
        }

        if (keyword.isNotEmpty) {
          final bool matchesQuery =
              asset.name.toLowerCase().contains(keyword) ||
              asset.code.toLowerCase().contains(keyword);
          if (!matchesQuery) {
            return false;
          }
        }

        return true;
      })
      .toList(growable: false);
}

/// Jumlah chip filter aktif untuk badge (status terpilih + kategori).
/// Pencarian tidak dihitung.
int assetActiveFilterCount(Set<AssetStatus> statuses, String? category) {
  return filter_utils.filterBadgeCount(
    multiCount: statuses.length,
    hasSingle: category != null && category.trim().isNotEmpty,
  );
}

Set<AssetStatus> normalizeSelectedStatuses(Set<AssetStatus> selected) {
  // Semua nilai enum valid; salin agar tidak bergantung pada mutasi luar.
  return Set<AssetStatus>.from(selected);
}

String? normalizeSelectedAssetCategory(
  List<String> categories,
  String? selected,
) {
  return filter_utils.normalizeSelectedCategory(categories, selected);
}
