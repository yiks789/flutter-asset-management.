import 'dart:async';

/// Kontrak pengembalian aset. Bisa diganti implementasi HTTP di tahap berikutnya.
abstract interface class AssetReturnService {
  Future<void> returnAsset(String assetCode);
}

/// Stub pengembalian. Default selalu sukses; flag dipakai untuk simulasi error.
class StubAssetReturnService implements AssetReturnService {
  const StubAssetReturnService({this.simulateReturnError = false});

  final bool simulateReturnError;

  @override
  Future<void> returnAsset(String assetCode) {
    if (simulateReturnError) {
      return Future<void>.error(
        StateError('Simulasi gagal mengembalikan aset'),
      );
    }
    return Future<void>.value();
  }
}
