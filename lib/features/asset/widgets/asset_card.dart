import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/asset_item.dart';
import 'status_badge.dart';

/// Kartu aset yang bisa di-tap (aksi detail masih placeholder).
class AssetCard extends StatelessWidget {
  const AssetCard({super.key, required this.asset, required this.onTap});

  final AssetItem asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppDimensions.cardRadius);

    return Material(
      color: AppColors.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.cardLeftPadding,
            AppDimensions.cardTopPadding,
            AppDimensions.cardRightPadding,
            AppDimensions.cardBottomPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: AppColors.cardBorder,
              width: AppDimensions.cardBorderWidth,
            ),
            borderRadius: radius,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(asset.name, style: AppTextStyles.assetName),
                    const SizedBox(height: AppDimensions.nameMetaSpacing),
                    Text(
                      '${asset.code} · ${asset.category}',
                      style: AppTextStyles.assetMeta,
                    ),
                    const SizedBox(height: AppDimensions.metaBadgeSpacing),
                    StatusBadge(status: asset.status),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.cardIconSpacing),
              const Icon(
                Icons.chevron_right,
                size: AppDimensions.chevronSize,
                color: AppColors.chevron,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
