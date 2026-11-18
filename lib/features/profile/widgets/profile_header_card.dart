import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../utils/profile_initials.dart';

/// Kartu identitas pengguna di halaman Profil.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.profileCardVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.profileCardRadius),
        border: Border.all(
          color: AppColors.detailInfoBorder,
          width: AppDimensions.chipBorderWidth,
        ),
      ),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: AppDimensions.profileAvatarSize / 2,
            backgroundColor: AppColors.avatarBackground,
            child: Text(
              profileInitials(name),
              style: AppTextStyles.profileAvatarInitials,
            ),
          ),
          const SizedBox(height: AppDimensions.profileAvatarToName),
          Text(name, style: AppTextStyles.profileName),
          const SizedBox(height: AppDimensions.profileNameToEmail),
          Text(email, style: AppTextStyles.profileEmail),
        ],
      ),
    );
  }
}
