import 'package:flutter/foundation.dart';

import '../../../core/clock/app_clock.dart';
import '../models/asset_item.dart';
import '../models/asset_status.dart';
import '../models/loan_item.dart';
import 'dummy_assets.dart';
import 'dummy_loans.dart';

/// Sumber data bersama untuk Daftar, Detail, dan Riwayat (in-memory).
class AssetRepository extends ChangeNotifier {
  AssetRepository({
    List<AssetItem>? assets,
    List<LoanItem>? loans,
    AppClock? clock,
  }) : _assets = List<AssetItem>.from(assets ?? dummyAssets),
       _loans = List<LoanItem>.from(loans ?? dummyLoans),
       _clock = clock ?? const SystemClock();

  final List<AssetItem> _assets;
  final List<LoanItem> _loans;
  final AppClock _clock;

  AppClock get clock => _clock;
  List<AssetItem> get assets => List<AssetItem>.unmodifiable(_assets);
  List<LoanItem> get loans => List<LoanItem>.unmodifiable(_loans);

  AssetItem? assetByCode(String code) {
    for (final AssetItem asset in _assets) {
      if (asset.code == code) {
        return asset;
      }
    }
    return null;
  }

  /// Tandai aset sebagai dipinjam dan tambahkan loan aktif baru.
  void borrowAsset(String code, {DateTime? now}) {
    final int index = _assets.indexWhere((AssetItem item) => item.code == code);
    if (index == -1) {
      return;
    }

    _assets[index] = _assets[index].copyWith(status: AssetStatus.borrowed);
    final AssetItem asset = _assets[index];
    _loans.add(
      LoanItem(
        assetCode: asset.code,
        assetName: asset.name,
        borrowDate: now ?? _clock.now(),
      ),
    );
    notifyListeners();
  }

  /// Selesaikan loan aktif dan kembalikan status aset menjadi AVAILABLE.
  void returnAsset(String code, {DateTime? now}) {
    final int loanIndex = _loans.indexWhere(
      (LoanItem loan) => loan.assetCode == code && loan.isActive,
    );
    if (loanIndex == -1) {
      return;
    }

    final LoanItem loan = _loans[loanIndex];
    _loans[loanIndex] = LoanItem(
      assetCode: loan.assetCode,
      assetName: loan.assetName,
      borrowDate: loan.borrowDate,
      returnDate: now ?? _clock.now(),
    );

    final int assetIndex = _assets.indexWhere(
      (AssetItem item) => item.code == code,
    );
    if (assetIndex != -1) {
      _assets[assetIndex] = _assets[assetIndex].copyWith(
        status: AssetStatus.available,
      );
    }
    notifyListeners();
  }
}
