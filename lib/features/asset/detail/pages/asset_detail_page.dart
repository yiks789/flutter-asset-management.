import 'package:flutter/material.dart';

import '../../../../core/clock/app_clock.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/asset_borrow_service.dart';
import '../../data/asset_repository.dart';
import '../../data/asset_repository_scope.dart';
import '../../models/asset_item.dart';
import '../../models/asset_status.dart';
import '../widgets/borrow_button.dart';
import '../widgets/detail_header.dart';
import '../widgets/error_banner.dart';
import '../widgets/info_card.dart';

/// Ubah menjadi true untuk mencoba ErrorBanner langsung di aplikasi.
const bool kSimulateConflictOnDemo = false;

/// Halaman detail aset. Menerima [AssetItem] langsung dari halaman daftar.
class AssetDetailPage extends StatefulWidget {
  const AssetDetailPage({
    super.key,
    required this.asset,
    this.borrowService,
    this.repository,
    this.clock,
  });

  final AssetItem asset;
  final AssetBorrowService? borrowService;
  final AssetRepository? repository;
  final AppClock? clock;

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  late final AssetBorrowService _service;
  late AssetStatus _status;
  AssetRepository? _repository;
  AppClock _clock = const SystemClock();
  bool _dependenciesResolved = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _status = widget.asset.status;
    _service =
        widget.borrowService ??
        const StubAssetBorrowService(simulateConflict: kSimulateConflictOnDemo);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dependenciesResolved) {
      return;
    }
    _repository = widget.repository ?? maybeAssetRepositoryOf(context);
    _clock = widget.clock ?? _repository?.clock ?? const SystemClock();
    _dependenciesResolved = true;
  }

  Future<void> _borrow() async {
    if (_status != AssetStatus.available || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _service.borrow(widget.asset.code);
      if (!mounted) {
        return;
      }

      _repository?.borrowAsset(widget.asset.code, now: _clock.now());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aset berhasil dipinjam')));
      setState(() {
        _status = AssetStatus.borrowed;
        _isLoading = false;
      });
      Navigator.of(context).pop<bool>(true);
    } on AssetBorrowConflictException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            'Aset ${error.assetCode} sudah dipinjam pengguna lain. Muat ulang daftar.';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Gagal meminjam aset. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      child: Container(
        width: AppDimensions.detailBackButtonSize,
        height: AppDimensions.detailBackButtonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
          border: Border.all(
            color: AppColors.detailInfoBorder,
            width: AppDimensions.chipBorderWidth,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: AppDimensions.detailBackIconSize,
          color: AppColors.detailTextPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.detailPageBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.horizontalPadding,
            AppDimensions.detailTopPadding,
            AppDimensions.horizontalPadding,
            AppDimensions.detailBottomSpacing,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _buildBackButton(),
                  const SizedBox(width: AppDimensions.detailAppBarSpacing),
                  Text('Detail Aset', style: AppTextStyles.detailAppBarTitle),
                ],
              ),
              const SizedBox(height: AppDimensions.detailHeaderTopSpacing),
              DetailHeader(
                name: widget.asset.name,
                code: widget.asset.code,
                status: _status,
              ),
              const SizedBox(height: AppDimensions.detailHeaderToCardSpacing),
              InfoCard(
                code: widget.asset.code,
                category: widget.asset.category,
                status: _status,
              ),
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: AppDimensions.detailErrorSpacing),
                ErrorBanner(message: _errorMessage!),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.detailInfoBorder,
              width: AppDimensions.chipBorderWidth,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.horizontalPadding,
              vertical: AppDimensions.detailBottomVerticalPadding,
            ),
            child: BorrowButton(
              status: _status,
              isLoading: _isLoading,
              onPressed: _borrow,
            ),
          ),
        ),
      ),
    );
  }
}
