import 'dart:async';

/// Exception untuk kondisi konflik (HTTP 409 pada implementasi nyata).
class AssetBorrowConflictException implements Exception {
  const AssetBorrowConflictException(this.assetCode);

  final String assetCode;

  @override
  String toString() => 'AssetBorrowConflictException: $assetCode';
}

/// Kontrak peminjaman aset. Bisa diganti implementasi HTTP di tahap berikutnya.
abstract interface class AssetBorrowService {
  Future<void> borrow(String assetCode);
}

/// Stub sementara. Default selalu sukses; flag dipakai untuk simulasi error.
class StubAssetBorrowService implements AssetBorrowService {
  const StubAssetBorrowService({
    this.simulateConflict = false,
    this.simulateGenericError = false,
  });

  /// Aset dengan kode ini selalu mengembalikan 409.
  static const String conflictAssetCode = 'AST-003';

  final bool simulateConflict;
  final bool simulateGenericError;

  @override
  Future<void> borrow(String assetCode) {
    if (simulateConflict || assetCode == conflictAssetCode) {
      return Future<void>.error(AssetBorrowConflictException(assetCode));
    }
    if (simulateGenericError) {
      return Future<void>.error(StateError('Simulasi error umum'));
    }
    return Future<void>.value();
  }
}
