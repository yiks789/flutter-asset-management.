import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Gaya teks memakai Inter dan seluruh ukuran/weight ditentukan di sini.
abstract final class AppTextStyles {
  static final TextStyle greeting = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final TextStyle pageTitle = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final TextStyle avatar = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.avatarText,
  );

  static final TextStyle searchInput = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static final TextStyle searchHint = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final TextStyle assetName = GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final TextStyle assetMeta = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final TextStyle badge = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle navLabelActive = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static final TextStyle navLabelInactive = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Gaya teks khusus halaman Detail Aset.
  static final TextStyle detailAppBarTitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle detailAssetName = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle detailAssetCode = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final TextStyle detailInfoLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle detailInfoValue = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle detailBadge = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static final TextStyle detailErrorText = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.errorText,
  );

  static final TextStyle detailBorrowButton = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );

  // Gaya teks khusus halaman Riwayat Saya.
  static final TextStyle historyTitle = GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle historyTabActive = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle historyTabInactive = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle historyFilterBadge = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );

  static final TextStyle historyActiveFilterChip = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static final TextStyle historySummary = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle historyCardName = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle historyCardMeta = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Gaya teks bottom sheet "Filter Riwayat".
  static final TextStyle filterSheetTitle = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle filterSheetSectionTitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle filterSheetHint = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final TextStyle filterChipSelected = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );

  static final TextStyle filterChipUnselected = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle historyReturnButton = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );

  static final TextStyle historyEmpty = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Gaya teks khusus halaman Profil.
  static final TextStyle profileAvatarInitials = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.avatarText,
  );

  static final TextStyle profileName = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle profileEmail = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final TextStyle profileStatLabel = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle profileStatValueBorrowed = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.borrowedForeground,
  );

  static final TextStyle profileStatValueReturned = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.detailBadgeAvailableForeground,
  );

  static final TextStyle logoutButton = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.errorIcon,
  );

  // Gaya teks khusus halaman Login.
  static final TextStyle loginTitle = GoogleFonts.inter(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle loginSubtitle = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static final TextStyle authLabel = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle authFieldInput = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.detailTextPrimary,
  );

  static final TextStyle authFieldError = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.errorText,
  );

  static final TextStyle loginButton = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );

  static final TextStyle loginNote = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
