import 'package:finality/common/utils/beat_countdown.dart';
import 'package:finality/data/socket/manic/manic_price_data.dart';
import 'package:finality/features/positions/live_position/model/live_position_item_data.dart';
import 'package:finality/features/positions/live_position/widgets/scanning_container.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/space_grotesk_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Active 状态的 item（简化版，高度 30）
/// 显示：进度条 + 方向图标 + 金额 + 预估收益
class ActiveItem extends StatefulWidget {
  const ActiveItem({
    super.key,
    required this.currentPrice,
    required this.data,
  });

  final ValueListenable<ManicPriceData?> currentPrice;
  final ActiveItemData data;

  @override
  State<ActiveItem> createState() => _ActiveItemState();
}

class _ActiveItemState extends State<ActiveItem> {
  late final ValueListenable<int?> _beat;
  late BeatCountdown _countdown;

  @override
  void initState() {
    super.initState();
    _beat = widget.currentPrice.toBeatNotifier();
    _countdown = _createCountdown();
    _countdown.start();
  }

  @override
  void didUpdateWidget(covariant ActiveItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.endTime != widget.data.endTime ||
        oldWidget.data.id != widget.data.id) {
      _countdown.dispose();
      _countdown = _createCountdown();
      _countdown.start();
    }
  }

  @override
  void dispose() {
    _countdown.dispose();
    super.dispose();
  }

  BeatCountdown _createCountdown() {
    return BeatCountdown(
      endTime: widget.data.endTime,
      beat: _beat,
    );
  }

  @override
  Widget build(BuildContext context) {
    var bullish = context.appColors.bullish;
    var bearish = context.appColors.bearish;
    var textColorPrimary = context.textColorTheme.textColorPrimary;
    final color = widget.data.isHigh ? bullish : bearish;
    final bgColor =
        widget.data.isHigh ? const Color(0xFF0F1A16) : const Color(0xFF0F1A16);

    return ValueListenableBuilder<int>(
      valueListenable: _countdown.remainingMs,
      builder: (context, remainingMs, _) {
        final durationMs = widget.data.durationMs;
        final progress =
            durationMs > 0 ? (remainingMs / durationMs).clamp(0.0, 1.0) : 0.0;
        final isSettling = remainingMs <= 0;

        final content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部进度条
            _TimeProgressBar(progress: progress, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // 方向图标
                    _DirectionIcon(isHigh: widget.data.isHigh),
                    Dimens.hGap4,
                    // 倒计时
                    Text(
                      _formatCountdown(remainingMs),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: SpaceGroteskFont.fontFamily,
                        color: remainingMs > 0 && remainingMs <= 5000
                            ? bearish
                            : textColorPrimary,
                        height: 1.3,
                        shadows: remainingMs > 0 && remainingMs <= 5000
                            ? [Shadow(color: bearish, blurRadius: 2.71)]
                            : null,
                        fontFeatures: const [
                          FontFeature.liningFigures(),
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // 预估收益
                    _buildPnlText(context),
                  ],
                ),
              ),
            ),
          ],
        );

        if (isSettling) {
          return ScanningContainer(
            width: 128,
            height: 30,
            scanColor: color,
            borderRadius: Dimens.radius6,
            backgroundColor: bgColor,
            child: content,
          );
        }

        return Container(
          width: 128,
          height: 30,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: Dimens.radius6,
            border: Border.all(color: color, width: 0.5),
            color: bgColor,
          ),
          child: content,
        );
      },
    );
  }

  String _formatCountdown(int ms) {
    if (ms <= 0) return '00.00';
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    // 取百分之一秒（十毫秒位）
    final centiseconds = (ms % 1000) ~/ 10;
    final ss = seconds.toString().padLeft(2, '0');
    final cs = centiseconds.toString().padLeft(2, '0');
    if (minutes > 0) {
      final mm = minutes.toString().padLeft(2, '0');
      return '$mm:$ss.$cs';
    }
    return '$ss.$cs';
  }

  Widget _buildPnlText(BuildContext context) {
    final winColor = widget.data.isHigh
        ? context.appColors.bullish
        : context.appColors.bearish;
    final loseColor = context.textColorTheme.textColorTertiary;
    final entryPrice = widget.data.entryPrice;

    return ValueListenableBuilder(
      valueListenable: widget.currentPrice,
      builder: (context, priceData, child) {
        var value = priceData?.close;
        final isGreaterEntryPrice = value != null && value > entryPrice;
        final isWin = widget.data.isHigh && isGreaterEntryPrice ||
            !widget.data.isHigh && !isGreaterEntryPrice;
        final color = isWin ? winColor : loseColor;
        final pnlText = isWin ? widget.data.wonProfit : widget.data.lostLoss;

        return Text(
          pnlText,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 10,
            height: 1,
            shadows: [
              Shadow(color: color, blurRadius: 2.71),
            ],
          ),
        );
      },
    );
  }
}

/// 顶部时间进度条
class _TimeProgressBar extends StatelessWidget {
  const _TimeProgressBar({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: progress,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(1),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 3.39,
                spreadRadius: 0.68,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 方向图标（12x12 彩色背景 + 箭头）
class _DirectionIcon extends StatelessWidget {
  const _DirectionIcon({required this.isHigh});

  final bool isHigh;

  @override
  Widget build(BuildContext context) {
    final color =
        isHigh ? context.appColors.bullish : context.appColors.bearish;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.88),
      ),
      child: Center(
        child: SvgPicture.asset(
          isHigh
              ? Assets.svgsIcTradingActionUp
              : Assets.svgsIcTradingActionDown,
          width: 10,
          height: 10,
          colorFilter: const ColorFilter.mode(
            Colors.black,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
