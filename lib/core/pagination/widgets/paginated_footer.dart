import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';

/// Footer yang hanya menampilkan loader kecil saat halaman sedang dimuat.
class PaginatedFooter extends StatelessWidget {
  const PaginatedFooter({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return const SizedBox.shrink();
    }

    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.paginationFooterPadding,
      ),
      child: Center(
        child: SizedBox(
          width: AppDimensions.detailProgressIndicatorSize,
          height: AppDimensions.detailProgressIndicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: AppDimensions.historyProgressStrokeWidth,
          ),
        ),
      ),
    );
  }
}
