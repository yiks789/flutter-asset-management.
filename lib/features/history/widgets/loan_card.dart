import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../asset/detail/widgets/status_badge.dart';
import '../../asset/models/asset_status.dart';
import '../../asset/models/loan_item.dart';
import '../utils/history_dates.dart';
import 'return_button.dart';

/// Kartu satu pinjaman pada halaman Riwayat Saya.
class LoanCard extends StatelessWidget {
  const LoanCard({
    super.key,
    required this.loan,
    required this.isReturning,
    required this.onReturn,
  });

  final LoanItem loan;
  final bool isReturning;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final bool active = loan.isActive;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.historyCardPadding),
      decoration: BoxDecoration(
        color: AppColors.historyCardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.historyCardRadius),
        border: Border.all(
          color: AppColors.historyCardBorder,
          width: AppDimensions.historyCardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(loan.assetName, style: AppTextStyles.historyCardName),
                    const SizedBox(
                      height: AppDimensions.historyCardMetaSpacing,
                    ),
                    Text(
                      loanSubtitle(loan),
                      style: AppTextStyles.historyCardMeta,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.cardIconSpacing),
              StatusBadge(
                status: active ? AssetStatus.borrowed : AssetStatus.available,
                label: active ? 'BORROWED' : 'RETURNED',
              ),
            ],
          ),
          if (active) ...<Widget>[
            const SizedBox(height: AppDimensions.historyCardSpacing),
            ReturnButton(isLoading: isReturning, onPressed: onReturn),
          ],
        ],
      ),
    );
  }
}
