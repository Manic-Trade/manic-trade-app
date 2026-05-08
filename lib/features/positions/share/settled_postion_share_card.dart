import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/features/utilities/share/holo_card_background.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/clash_display_font.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 已结算仓位分享卡片
///
/// 分 2 层：
///   - 背景层：全息光效动画 [HoloCardBackground]
///   - 前景层：Logo、PNL、交易详情
class SettledPositionShareCard extends StatelessWidget {
  /// 是否看涨（影响方向箭头和颜色）
  final bool isHigh;

  /// 是否盈利（影响 PNL 和 Profit 颜色）
  final bool isWin;

  /// PNL 百分比数字（如 "+25"）
  final String pnlDisplay;
  final String pnlSign;

  /// 副标题（如 "PNL · LAYER/USDC"）
  final String subtitle;

  /// 右上角信息（如 "SHORT · SINGLE"）
  final String headerInfo;

  /// 方向文字（如 "Short" / "Long"）
  final String directionDisplay;

  /// 持续时间（如 "1m"）
  final String durationDisplay;

  /// 收益（如 "+$2.46"）
  final String profitDisplay;

  /// 开仓价格（如 "$0.08270"）
  final String entryPriceDisplay;

  /// 平仓价格（如 "$0.08269"）
  final String closePriceDisplay;

  /// 投入金额（如 "$10.00"）
  final String investedDisplay;

  final bool isAgent;
  const SettledPositionShareCard({
    super.key,
    required this.isHigh,
    required this.isWin,
    required this.pnlDisplay,
    required this.pnlSign,
    required this.subtitle,
    required this.headerInfo,
    required this.directionDisplay,
    required this.durationDisplay,
    required this.profitDisplay,
    required this.entryPriceDisplay,
    required this.closePriceDisplay,
    required this.investedDisplay,
    required this.isAgent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF161616),
        // 外发光
        boxShadow: const [
          BoxShadow(
            color: Color(0xCC000000),
            offset: Offset(2, 4),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: AspectRatio(
          aspectRatio: 0.8,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── 背景层 ──
              HoloCardBackground(
                  accentColor: isWin
                      ? context.appColors.bullish
                      : context.appColors.bearish,
                  backgroundColor: context.colorScheme.surfaceContainerHigh),

              // ── 前景内容层 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildHeroSection()),
                    _buildBottomSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 顶部：Logo + "MANIC" + 右侧信息 ──

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: isAgent ? 16 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(Assets.svgsAppLogo, width: 20, height: 19),
              const SizedBox(width: 8),
              Text(
                'MANIC',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.325,
                  height: 1.0,
                ).toDrukWide(),
              ),
            ],
          ),
          _buildHeaderInfo(),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    if (isAgent) {
      return Row(
        children: [
          Image.asset(Assets.agentAvatar, width: 28, height: 28),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TRADE BY AGENT',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDB8300),
                  letterSpacing: 0.4,
                  height: 1.2,
                ),
              ),
              Text(
                headerInfo.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0x66FFFFFF),
                  letterSpacing: 0.4,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Text(
      headerInfo.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Color(0x59FFFFFF),
        letterSpacing: 0.5,
        height: 1.0,
      ),
    );
  }

  // ── 中心：大号 PNL 百分比 + 副标题 ──

  Widget _buildHeroSection() {
    final pnlColor = isWin ? const Color(0xFF66FFB8) : const Color(0xFFF6523D);
    final pnlGlowColor =
        isWin ? const Color(0x8000D385) : const Color(0x80FF412C);
    final percentColor =
        isWin ? const Color(0x4066FFB8) : const Color(0x40FF8A7A);
    final signColor = isWin ? const Color(0x9966FFB8) : const Color(0x99FF8A7A);
    final signGlowColor =
        isWin ? const Color(0x8000D385) : const Color(0x80FF412C);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 大号数字 + %
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 符号贴顶（对齐 web align-self: flex-start）
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    pnlSign,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: signColor,
                      height: 1.1,
                      shadows: [
                        Shadow(blurRadius: 10, color: signGlowColor),
                      ],
                    ).toDrukWide(),
                  ),
                ),
              ),
              Text(
                pnlDisplay,
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w700,
                  color: pnlColor,
                  letterSpacing: 0.8,
                  height: 0.85,
                  shadows: [
                    Shadow(
                        blurRadius: 12,
                        color: pnlGlowColor.withValues(alpha: 0.7)),
                    Shadow(
                        blurRadius: 40,
                        color: pnlGlowColor.withValues(alpha: 0.35)),
                    Shadow(
                        blurRadius: 80,
                        color: pnlGlowColor.withValues(alpha: 0.15)),
                    const Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Color(0x66000000),
                    ),
                  ],
                ).toDrukWide(),
              ),
              // % 贴底对齐数字 baseline
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  '%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: percentColor,
                    height: 1,
                    shadows: [
                      Shadow(
                          blurRadius: 12,
                          color: pnlGlowColor.withValues(alpha: 0.3)),
                    ],
                  ).toDrukWide(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // 副标题 + 装饰线
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0x33FFFFFF)],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              subtitle.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0x66FFFFFF),
                letterSpacing: 2.2,
                height: 1.5,
              ).toClashDisplay(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0x33FFFFFF), Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 底部：2行统计 + 水印 ──

  Widget _buildBottomSection(BuildContext context) {
    final directionColor =
        isHigh ? context.appColors.bullish : context.appColors.bearish;
    final profitColor =
        isWin ? context.appColors.bullish : context.appColors.bearish;

    var white90 = Colors.white.withValues(alpha: 0.9);
    var white80 = Colors.white.withValues(alpha: 0.8);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                value: directionDisplay,
                label: 'Direction',
                valueColor: directionColor,
                icon: isHigh
                    ? Assets.svgsIcTradingActionUpRound
                    : Assets.svgsIcTradingActionDownRound,
                iconColor: directionColor,
              ),
              _buildStatItem(
                value: durationDisplay,
                label: 'Duration',
                valueColor: white90,
              ),
              _buildStatItem(
                value: profitDisplay,
                label: 'Profit',
                valueColor: profitColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                value: entryPriceDisplay,
                label: 'Entry',
                valueColor: white80,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              _buildStatItem(
                value: closePriceDisplay,
                label: 'Close',
                valueColor: white80,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              _buildStatItem(
                value: investedDisplay,
                label: 'Invested',
                valueColor: white80,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 水印
          Text(
            'MANIC TRADE',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0x14FFFFFF),
              letterSpacing: 2.0,
            ).toDrukWide(),
          ),
        ],
      ),
    );
  }

  /// 单个统计项
  Widget _buildStatItem({
    required String value,
    required String label,
    required Color valueColor,
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w700,
    String? icon,
    Color? iconColor,
  }) {
    final valueWidget = Text(
      value,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: valueColor,
        letterSpacing: 0,
        height: 1.0,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  icon,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    iconColor ?? valueColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 2),
                Flexible(child: valueWidget),
              ],
            )
          else
            valueWidget,
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0x59FFFFFF),
              letterSpacing: 0.5,
            ).toClashDisplay(),
          ),
        ],
      ),
    );
  }
}
