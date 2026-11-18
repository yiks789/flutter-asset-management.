import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../asset/detail/widgets/info_row.dart';

/// Kartu info profil yang memakai ulang InfoRow dari Detail Aset.
class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.name,
    required this.email,
    required this.division,
  });

  final String name;
  final String email;
  final String division;

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
          InfoRow(label: 'Nama', value: name),
          const Divider(
            height: AppDimensions.detailDividerHeight,
            thickness: AppDimensions.detailDividerHeight,
            color: AppColors.detailDivider,
          ),
          InfoRow(label: 'Email', value: email),
          const Divider(
            height: AppDimensions.detailDividerHeight,
            thickness: AppDimensions.detailDividerHeight,
            color: AppColors.detailDivider,
          ),
          InfoRow(label: 'Divisi', value: division),
        ],
      ),
    );
  }
}
