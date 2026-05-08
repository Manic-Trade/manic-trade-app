import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/features/deposit/widgets/usdc_status_icon.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// 充值已收到、处理中状态卡片
class SweepingCard extends StatelessWidget {
  final VoidCallback onClose;

  const SweepingCard({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UsdcStatusIcon(showCheck: false, processing: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEPOSIT RECEIVED\nAND PROCESSING..',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                      fontSize: 20),
                ),
                Dimens.vGap6,
                Text(
                  'Your deposit has been credited to your account shortly.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF969696),
                      height: 1.23),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Touchable.plain(
                onTap: onClose,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: const Icon(
                      RemixIcons.close_large_line,
                      size: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
