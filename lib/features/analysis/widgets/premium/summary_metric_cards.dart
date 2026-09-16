import 'dart:ui' as ui;

import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 3 张摘要数据卡（Net P&L / Total Trades / Total Volume）
///
/// 参考 Web 端 SummaryMetricCard (premium-view.tsx L419-L547)
/// 移动端 2 列网格布局（grid-cols-2 gap-3）
class SummaryMetricCards extends StatelessWidget {
  final List<SummaryMetricVO> metrics;

  const SummaryMetricCards({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    // 2 列网格布局，与 web 端 grid-cols-2 gap-3 一致
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (int i = 0; i < metrics.length; i++)
          SizedBox(
            // 前两张各占半宽，第三张也占半宽（左对齐）
            width: (MediaQuery.sizeOf(context).width - 32 - 12) / 2,
            child: _SummaryMetricCard(
              metric: metrics[i],
              iconAsset: _iconForLabel(metrics[i].label),
            ),
          ),
      ],
    );
  }

  /// 根据 label 返回对应图标 asset
  static String? _iconForLabel(String label) {
    return switch (label) {
      'Net P&L' => Assets.svgsChartStyleLine,
      'Total Trades' => Assets.svgsIcFlashLine,
      'Total Volume' => Assets.svgsChartStyleArea,
      _ => null,
    };
  }
}

class _SummaryMetricCard extends StatelessWidget {
  final SummaryMetricVO metric;
  final String? iconAsset;

  const _SummaryMetricCard({
    required this.metric,
    this.iconAsset,
  });

  Color get _toneColor => switch (metric.tone) {
        MetricTone.green => kPremiumGreen,
        MetricTone.red => kPremiumRed,
        MetricTone.amber => kPremiumOrange,
      };

  @override
  Widget build(BuildContext context) {
    // 分离符号和数值（与 web 一致）
    final signMatch = RegExp(r'^([+-])').firstMatch(metric.value);
    final sign = signMatch?.group(1) ?? '';
    final displayValue =
        sign.isNotEmpty ? metric.value.substring(1) : metric.value;

    // 解析 subValue: "50W / 8L" → "50 wins | 8 losses"
    final wlMatch = RegExp(r'^(\d+)W / (\d+)L$').firstMatch(metric.subValue);

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶行：label + icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: kPremiumOrange.withValues(alpha: 0.4),
                  letterSpacing: 1.0,
                ),
              ),
              if (iconAsset != null)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 外层投影: 0px 0px 14px #FF99004D
                    ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: 7,
                        sigmaY: 7,
                      ),
                      child: SvgPicture.asset(
                        iconAsset!,
                        width: 15,
                        height: 15,
                        colorFilter: ColorFilter.mode(
                          const Color(0x4DFF9900),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    // 内层投影: 0px 0px 6px #FF99008C
                    ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: 3,
                        sigmaY: 3,
                      ),
                      child: SvgPicture.asset(
                        iconAsset!,
                        width: 15,
                        height: 15,
                        colorFilter: ColorFilter.mode(
                          const Color(0x8CFF9900),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    // 图标本体
                    SvgPicture.asset(
                      iconAsset!,
                      width: 15,
                      height: 15,
                      colorFilter: ColorFilter.mode(
                        kPremiumOrange.withValues(alpha: 0.6),
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          // 底行：value + subValue
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (sign.isNotEmpty)
                Text(
                  sign,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _toneColor.withValues(alpha: 0.5),
                  ),
                ),
              Text(
                displayValue,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _toneColor,
                  letterSpacing: 0.4,
                  shadows: [
                    Shadow(
                      color: _toneColor.withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                    Shadow(
                      color: _toneColor.withValues(alpha: 0.18),
                      blurRadius: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Dimens.vGap4,
          // subValue（W/L 格式特殊处理）
          if (wlMatch != null)
            _buildWinLossText(wlMatch.group(1)!, wlMatch.group(2)!)
          else
            Text(
              sign + metric.subValue,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _subValueColor,
                  height: 1.333),
            ),
        ],
      ),
    );
  }

  Color get _subValueColor => switch (metric.tone) {
        MetricTone.green => kPremiumGreen,
        MetricTone.red => kPremiumRed,
        _ => Colors.white.withValues(alpha: 0.3),
      };

  /// "50 wins | 8 losses" 格式（与 web 一致）
  Widget _buildWinLossText(String wins, String losses) {
    return Row(
      children: [
        Text(
          '$wins wins',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.3),
            fontFeatures: const [FontFeature.tabularFigures()],
            letterSpacing: 0.3,
          ),
        ),
        Container(
          width: 1,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: Colors.white.withValues(alpha: 0.1),
        ),
        Text(
          '$losses losses',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.3),
            fontFeatures: const [FontFeature.tabularFigures()],
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
