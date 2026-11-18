import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/asset_status.dart';
import 'status_badge.dart';

/// Nama aset, kode aset, dan badge status pada bagian atas detail.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.name,
    required this.code,
    required this.status,
  });

  final String name;
  final String code;
  final AssetStatus status;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Text(name, style: AppTextStyles.detailAssetName)),
            const SizedBox(width: AppDimensions.detailHeaderNameBadgeSpacing),
            StatusBadge(status: status),
          ],
        ),
        const SizedBox(height: AppDimensions.detailHeaderCodeSpacing),
        Text(code, style: AppTextStyles.detailAssetCode),
      ],
    );
  }
}
