import 'package:flutter/widgets.dart';

import '../../../core/clock/app_clock.dart';
import 'asset_repository.dart';

/// Menyediakan [AssetRepository] (dan jamnya) ke seluruh widget di bawahnya.
class AssetRepositoryScope extends StatefulWidget {
  const AssetRepositoryScope({
    super.key,
    this.repository,
    AppClock? clock,
    required this.child,
  }) : _clock = clock;

  final AssetRepository? repository;
  final AppClock? _clock;
  final Widget child;

  @override
  State<AssetRepositoryScope> createState() => _AssetRepositoryScopeState();
}

class _AssetRepositoryScopeState extends State<AssetRepositoryScope> {
  late final AssetRepository _repository =
      widget.repository ?? AssetRepository(clock: widget._clock);

  @override
  Widget build(BuildContext context) {
    return _InheritedAssetRepository(
      repository: _repository,
      child: widget.child,
    );
  }
}

class _InheritedAssetRepository extends InheritedNotifier<AssetRepository> {
  const _InheritedAssetRepository({
    required AssetRepository repository,
    required super.child,
  }) : super(notifier: repository);

  static AssetRepository? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedAssetRepository>()
        ?.notifier;
  }
}

/// Ambil repository terdekat. Harus dipanggil di bawah [AssetRepositoryScope].
AssetRepository assetRepositoryOf(BuildContext context) {
  final AssetRepository? repository = _InheritedAssetRepository.maybeOf(
    context,
  );
  assert(repository != null, 'AssetRepositoryScope tidak ditemukan.');
  return repository!;
}

/// Versi opsional untuk widget yang tetap bisa dipakai tanpa scope (test).
AssetRepository? maybeAssetRepositoryOf(BuildContext context) {
  return _InheritedAssetRepository.maybeOf(context);
}
