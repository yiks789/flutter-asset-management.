import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Sapaan, judul halaman, dan avatar inisial.
class AssetHeader extends StatelessWidget {
  const AssetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.horizontalPadding,
        AppDimensions.headerTopPadding,
        AppDimensions.horizontalPadding,
        0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Halo, Rina', style: AppTextStyles.greeting),
                SizedBox(height: AppDimensions.headerTextSpacing),
                Text('Daftar Aset', style: AppTextStyles.pageTitle),
              ],
            ),
          ),
          CircleAvatar(
            radius: AppDimensions.avatarDiameter / 2,
            backgroundColor: AppColors.avatarBackground,
            child: Text('RP', style: AppTextStyles.avatar),
          ),
        ],
      ),
    );
  }
}
