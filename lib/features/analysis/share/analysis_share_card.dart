import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/crt_glitch_effect.dart';
import 'package:finality/features/utilities/share/holo_card_background.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/clash_display_font.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 已结算仓位分享卡片（Win Rate 变体）
///
/// 分 2 层：
///   - 背景层：全息光效动画 [HoloCardBackground]
///   - 前景层：Logo、核心数据、统计栏
class AnalysisShareCard extends StatelessWidget {
  final int winRatePercent;
  final int wins;
  final int totalTrades;
  final int losses;
  final String subtitle;

  const AnalysisShareCard({
    super.key,
    required this.winRatePercent,
    required this.wins,
    required this.totalTrades,
    required this.losses,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF161616),
        // pc-behind：外发光
        boxShadow: const [
          BoxShadow(
            color: Color(0xCC000000), // rgba(0,0,0,0.8)
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
                  accentColor: context.colorScheme.primary,
                  backgroundColor: context.colorScheme.surfaceContainerHigh),

              // ── 前景内容层 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildHeroSection()),
                    _buildBottomSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 顶部：Logo + "MANIC" ─────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
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
    );
  }

  // ── 中心：大号百分比 + 副标题 ────────────────────────────────────

  Widget _buildHeroSection() {
    //final kOrange = Color(0xFFFFDFB3);
    final kOrange = Color(0xFFFF9900);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 大号数字 + %
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // 主数字
            CrtGlitchEffect(
              child: Text(
                '$winRatePercent',
                style: TextStyle(
                  fontSize: 88,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFCC80),
                  letterSpacing: 0.8,
                  height: 0.82, // 72.16 / 88
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                    Shadow(
                      color: kOrange.withValues(alpha: 0.7),
                      blurRadius: 12,
                    ),
                    Shadow(
                      color: kOrange.withValues(alpha: 0.35),
                      blurRadius: 40,
                    ),
                    Shadow(
                      color: kOrange.withValues(alpha: 0.15),
                      blurRadius: 80,
                    ),
                  ],
                ).toDrukWide(),
              ),
            ),
            // % 符号
            Text(
              '%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0x40FF9900), // 25% 透明度
                shadows: const [
                  Shadow(
                    blurRadius: 12,
                    color: Color(0x33FF9900),
                  ),
                ],
              ).toDrukWide(),
            ),
          ],
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
                color: Color(0x66FFFFFF), // 40% 透明度
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

  // ── 底部：统计栏 + 水印 ──────────────────────────────────────────

  Widget _buildBottomSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 统计栏：Wins | Trades | Losses
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wins
            _buildStatItem(
              value: '$wins',
              label: 'Wins',
              valueColor: const Color(0xFF00D385),
              dotColor: const Color(0x9900D385), // 60% 透明度
            ),

            const SizedBox(width: 28),

            // Trades（中间列，带左右边框）
            Container(
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(
                    color: Color(0x1AFFFFFF), // 10% 透明度
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 29),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$totalTrades',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xE6FFFFFF), // 90% 透明度
                      height: 1.0,
                    ).toClashDisplay(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TRADES',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0x59FFFFFF), // 35% 透明度
                      letterSpacing: 0.5,
                    ).toClashDisplay(),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 28),

            // Losses
            _buildStatItem(
              value: '$losses',
              label: 'Losses',
              valueColor: const Color(0xFFFF412C),
              dotColor: const Color(0x99FF412C), // 60% 透明度
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
            color: Color(0x14FFFFFF), // 8% 透明度
            letterSpacing: 2.0,
          ).toDrukWide(),
        ),
      ],
    );
  }

  /// 单个统计项（Wins / Losses）
  Widget _buildStatItem({
    required String value,
    required String label,
    required Color valueColor,
    required Color dotColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: valueColor,
            height: 1.0,
          ).toClashDisplay(),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0x59FFFFFF), // 35% 透明度
                letterSpacing: 0.5,
              ).toClashDisplay(),
            ),
          ],
        ),
      ],
    );
  }
}
