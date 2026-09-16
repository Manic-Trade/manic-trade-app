import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/data/network/model/ua/ua_models.dart';
import 'package:finality/features/deposit/widgets/usdc_status_icon.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

/// 充值成功状态卡片，支持展开/收起交易详情
class SuccessCard extends StatefulWidget {
  final UASweepData? sweepResult;
  final VoidCallback onClose;

  const SuccessCard({
    super.key,
    required this.sweepResult,
    required this.onClose,
  });

  @override
  State<SuccessCard> createState() => _SuccessCardState();
}

class _SuccessCardState extends State<SuccessCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final result = widget.sweepResult;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部内容行
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UsdcStatusIcon(showCheck: true, processing: false),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEPOSIT COMPLETED',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                    Dimens.vGap4,
                    Text(
                      'Your deposit has been credited to your account.',
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
                    onTap: widget.onClose,
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
        ),
        // 展开的详情
        if (_expanded && result != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _SuccessDetails(result: result),
          ),
        // See More / See less
        const Divider(height: 1, color: Color(0xFF262626)),
        Touchable.plain(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                _expanded ? 'See Less' : 'See More',
                style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        Dimens.vGap16
      ],
    );
  }
}

// ── 交易详情列表 ──────────────────────────────────────────────

class _SuccessDetails extends StatelessWidget {
  final UASweepData result;

  const _SuccessDetails({required this.result});

  String _truncateHash(String hash) {
    if (hash.length <= 12) return hash;
    return '${hash.substring(0, 4)}...${hash.substring(hash.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080808),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF262626)),
      ),
      child: Column(
        children: [
          _DetailLinkRow(
            label: 'Deposit tx',
            value: _truncateHash(result.solanaTxHash),
            url: result.explorerUrl,
          ),
          const Divider(height: 1, color: Color(0xFF262626)),
          _DetailLinkRow(
            label: 'Completion tx',
            value: _truncateHash(result.transactionId),
            url: result.explorerUrl,
          ),
          const Divider(height: 1, color: Color(0xFF262626)),
          _DetailTextRow(
            label: 'Amount',
            value: '\$${result.transferAmount.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }
}

// ── 详情行：带外链跳转 ────────────────────────────────────────

class _DetailLinkRow extends StatelessWidget {
  final String label;
  final String value;
  final String url;

  const _DetailLinkRow({
    required this.label,
    required this.value,
    required this.url,
  });

  Future<void> _openUrl() async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF666666), fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _openUrl,
            child: Row(
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.open_in_new,
                    size: 12, color: Color(0xFF838383)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 详情行：纯文字 ────────────────────────────────────────────

class _DetailTextRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailTextRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF666666), fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
