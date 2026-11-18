import 'package:flutter/material.dart';

/// Seluruh warna aplikasi dikumpulkan di sini agar nilainya tidak tersebar.
abstract final class AppColors {
  static const Color pageBackground = Color(0xFFF3F5F7);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A2233);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color border = Color(0xFFD9DEE4);
  static const Color cardBorder = Color(0xFFE3E7EC);

  static const Color primary = Color(0xFF0F766E);
  static const Color navPillBackground = Color(0xFFD9EFEA);

  static const Color avatarBackground = Color(0xFF134E48);
  static const Color avatarText = Color(0xFFFFFFFF);

  static const Color availableBackground = Color(0xFFDCF5E4);
  static const Color availableForeground = Color(0xFF1F7A3D);

  static const Color borrowedBackground = Color(0xFFFDEBC0);
  static const Color borrowedForeground = Color(0xFF8A4B0A);

  static const Color maintenanceBackground = Color(0xFFE5E7EB);
  static const Color maintenanceForeground = Color(0xFF374151);

  /// Chevron memakai warna teks sekunder agar tetap dalam satu palet.
  static const Color chevron = textSecondary;

  // Palet khusus halaman Detail Aset.
  static const Color detailPageBackground = Color(0xFFF3F4F6);
  static const Color detailTextPrimary = Color(0xFF1F2937);
  static const Color detailDivider = Color(0xFFF0F1F3);
  static const Color detailInfoBorder = Color(0xFFE5E7EB);

  static const Color detailBadgeAvailableBackground = Color(0xFFDCFCE7);
  static const Color detailBadgeAvailableForeground = Color(0xFF166534);

  static const Color errorBackground = Color(0xFFFEE2E2);
  static const Color errorIcon = Color(0xFFB91C1C);
  static const Color errorText = Color(0xFF991B1B);

  static const Color disabledBackground = Color(0xFFD1D5DB);
  static const Color disabledText = Color(0xFF9CA3AF);

  // Palet khusus halaman Riwayat Saya.
  static const Color historyTabBackground = Color(0xFFE5E7EB);
  static const Color historyCardBackground = Color(0xFFECF6F4);
  static const Color historyCardBorder = Color(0xFFB8DDD5);
  static const Color historyChipBackground = Color(0xFFFFFFFF);

  // Filter Riwayat: field, tombol, badge, dan chip aktif.
  static const Color filterFieldBorder = Color(0xFFD1D5DB);
  static const Color filterActiveChipBackground = Color(0xFFE6F4F1);
  static const Color filterBadgeBackground = avatarBackground;

  // Border field form login (nilai sama dengan disabledText, dibuat semantik).
  static const Color formBorder = Color(0xFF9CA3AF);
}
