import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Item navigasi bawah. Gaya visual sengaja disamakan untuk semua tab.
@immutable
class AppNavItem {
  const AppNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Bottom navigation kustom agar pill ikon aktif berukuran 56x32.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, this.activeIndex = 0, this.onTap});

  static const List<AppNavItem> items = <AppNavItem>[
    AppNavItem(icon: Icons.inventory_2_outlined, label: 'Aset'),
    AppNavItem(icon: Icons.schedule, label: 'Riwayat'),
    AppNavItem(icon: Icons.person_outline, label: 'Profil'),
  ];

  final int activeIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.cardBorder,
            width: AppDimensions.navBorderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimensions.navHeight,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    item: items[i],
                    active: i == activeIndex,
                    onTap: onTap == null ? null : () => onTap!(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final AppNavItem item;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: AppDimensions.navIconPillWidth,
            height: AppDimensions.navIconPillHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.navPillBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
            ),
            child: Icon(
              item.icon,
              size: AppDimensions.navIconSize,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimensions.navLabelSpacing),
          Text(
            item.label,
            style: active
                ? AppTextStyles.navLabelActive
                : AppTextStyles.navLabelInactive,
          ),
        ],
      ),
    );
  }
}
