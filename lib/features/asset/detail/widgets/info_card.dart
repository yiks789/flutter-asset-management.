import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../models/asset_status.dart';
import 'info_row.dart';

/// Kartu putih berisi tiga baris informasi dengan divider di antaranya.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.code,
    required this.category,
    required this.status,
  });

  final String code;
  final String category;
  final AssetStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.detailInfoCardHorizontalPadding,
        vertical: AppDimensions.detailInfoCardVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.detailInfoCardRadius),
        border: Border.all(
          color: AppColors.detailInfoBorder,
          width: AppDimensions.chipBorderWidth,
        ),
      ),
      child: Column(
        children: <Widget>[
          InfoRow(label: 'Kode', value: code),
          const Divider(
            height: AppDimensions.detailDividerHeight,
            thickness: AppDimensions.detailDividerHeight,
            color: AppColors.detailDivider,
          ),
          InfoRow(label: 'Kategori', value: category),
          const Divider(
            height: AppDimensions.detailDividerHeight,
            thickness: AppDimensions.detailDividerHeight,
            color: AppColors.detailDivider,
          ),
          InfoRow(label: 'Status', value: status.name.toUpperCase()),
        ],
      ),
    );
  }
}
