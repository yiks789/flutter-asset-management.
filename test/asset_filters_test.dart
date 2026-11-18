import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/features/asset/data/dummy_assets.dart';
import 'package:flutter_application_1/features/asset/models/asset_item.dart';
import 'package:flutter_application_1/features/asset/models/asset_status.dart';
import 'package:flutter_application_1/features/asset/utils/asset_filters.dart';

void main() {
  group('assetsForFilters', () {
    test('status kosong berarti semua status', () {
      final List<AssetItem> result = assetsForFilters(
        dummyAssets,
        const <AssetStatus>{},
        null,
        '',
      );

      expect(result, hasLength(dummyAssets.length));
    });

    test('OR di dalam grup status, AND dengan kategori dan pencarian', () {
      final List<AssetItem> result = assetsForFilters(
        dummyAssets,
        <AssetStatus>{AssetStatus.available, AssetStatus.borrowed},
        'Laptop',
        'thinkpad',
      );

      expect(result.map((AssetItem a) => a.code), <String>[
        'AST-001',
        'AST-008',
        'AST-024',
      ]);
    });

    test('pencarian memakai nama atau kode, trim dan abaikan huruf', () {
      expect(
        assetsForFilters(
          dummyAssets,
          const <AssetStatus>{},
          null,
          '  macbook  ',
        ).map((AssetItem a) => a.code),
        containsAll(<String>['AST-002', 'AST-012']),
      );
      expect(
        assetsForFilters(
          dummyAssets,
          const <AssetStatus>{},
          null,
          'AST-020',
        ).map((AssetItem a) => a.code),
        <String>['AST-020'],
      );
    });

    test('kategori null berarti semua kategori', () {
      final List<AssetItem> onlyStatus = assetsForFilters(
        dummyAssets,
        <AssetStatus>{AssetStatus.maintenance},
        null,
        '',
      );
      expect(onlyStatus.every((AssetItem a) => a.status == AssetStatus.maintenance),
          isTrue);
      expect(onlyStatus, isNotEmpty);
    });

    test('hasil kosong saat tidak ada yang cocok', () {
      final List<AssetItem> result = assetsForFilters(
        dummyAssets,
        <AssetStatus>{AssetStatus.maintenance},
        'Laptop',
        '',
      );
      expect(result, isEmpty);
    });
  });

  group('categoriesForAssets', () {
    test('mengembalikan kategori unik, trim, non-kosong, urut abjad', () {
      const List<AssetItem> assets = <AssetItem>[
        AssetItem(
          id: '1',
          name: 'A',
          code: 'A-1',
          category: 'Laptop',
          status: AssetStatus.available,
        ),
        AssetItem(
          id: '2',
          name: 'B',
          code: 'B-1',
          category: ' Aksesoris ',
          status: AssetStatus.available,
        ),
        AssetItem(
          id: '3',
          name: 'C',
          code: 'C-1',
          category: 'Laptop',
          status: AssetStatus.borrowed,
        ),
        AssetItem(
          id: '4',
          name: 'D',
          code: 'D-1',
          category: '',
          status: AssetStatus.available,
        ),
      ];

      expect(categoriesForAssets(assets), <String>['Aksesoris', 'Laptop']);
    });

    test('kategori dummy stabil dan urut abjad', () {
      expect(categoriesForAssets(dummyAssets), <String>[
        'Aksesoris',
        'Jaringan',
        'Laptop',
        'Peralatan Kantor',
        'Smartphone',
        'Tablet',
      ]);
    });
  });

  group('assetActiveFilterCount', () {
    test('menghitung status terpilih + kategori, bukan pencarian', () {
      expect(
        assetActiveFilterCount(const <AssetStatus>{}, null),
        0,
      );
      expect(
        assetActiveFilterCount(<AssetStatus>{AssetStatus.available}, null),
        1,
      );
      expect(
        assetActiveFilterCount(
          <AssetStatus>{AssetStatus.available, AssetStatus.borrowed},
          'Laptop',
        ),
        3,
      );
    });
  });

  group('normalisasi', () {
    test('normalizeSelectedStatuses menyalin set', () {
      final Set<AssetStatus> selected = <AssetStatus>{AssetStatus.available};
      final Set<AssetStatus> normalized = normalizeSelectedStatuses(selected);
      selected.add(AssetStatus.borrowed);
      expect(normalized, <AssetStatus>{AssetStatus.available});
    });

    test('normalizeSelectedAssetCategory membuang kategori yang hilang', () {
      const List<String> categories = <String>['Laptop', 'Tablet'];
      expect(normalizeSelectedAssetCategory(categories, null), isNull);
      expect(normalizeSelectedAssetCategory(categories, 'Laptop'), 'Laptop');
      expect(normalizeSelectedAssetCategory(categories, 'Aksesoris'), isNull);
    });
  });
}
