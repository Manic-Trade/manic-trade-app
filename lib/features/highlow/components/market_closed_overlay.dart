import 'dart:async';

import 'package:finality/data/drift/entities/options_trading_schedule.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// 市场关闭遮罩层
/// 
/// 当市场关闭时显示遮罩和倒计时，倒计时结束后自动显示 [child]
class MarketClosedOverlay extends StatefulWidget {
  const MarketClosedOverlay({
    super.key,
    required this.child,
    this.tradingSchedule,
  });

  /// 开盘后显示的内容
  final Widget child;
  final OptionsTradingSchedule? tradingSchedule;

  @override
  State<MarketClosedOverlay> createState() => _MarketClosedOverlayState();
}

class _MarketClosedOverlayState extends State<MarketClosedOverlay> {
  DateTime? _openDateTime;
  String? _formattedTime;
  bool _isMarketOpen = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initOpenDateTime();
    _updateFormattedTime();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant MarketClosedOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tradingSchedule?.nextOpenTime !=
        widget.tradingSchedule?.nextOpenTime) {
      _initOpenDateTime();
      _updateFormattedTime();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initOpenDateTime() {
    final nextOpenTimeSeconds = widget.tradingSchedule?.nextOpenTime;
    _openDateTime = nextOpenTimeSeconds != null
        ? DateTime.fromMillisecondsSinceEpoch(nextOpenTimeSeconds * 1000)
        : null;
  }

  void _startTimer() {
    // 每秒更新一次
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateFormattedTime();
    });
  }

  void _updateFormattedTime() {
    final openDateTime = _openDateTime;
    if (openDateTime == null) {
      _formattedTime = null;
      _isMarketOpen = true;
      if (mounted) setState(() {});
      return;
    }

    final duration = openDateTime.difference(DateTime.now());
    if (duration.isNegative) {
      // 倒计时结束，市场已开盘
      _formattedTime = null;
      _isMarketOpen = true;
      _timer?.cancel();
    } else {
      _formattedTime = _formatDuration(duration);
      _isMarketOpen = false;
    }

    if (mounted) setState(() {});
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      // 超过一天：显示 xxD:xxh:xxm
      return "${days.toString().padLeft(2, '0')}D:"
          "${hours.toString().padLeft(2, '0')}h:"
          "${minutes.toString().padLeft(2, '0')}m";
    } else {
      // 少于一天：显示 xxh:xxm:xxs
      return "${hours.toString().padLeft(2, '0')}h:"
          "${minutes.toString().padLeft(2, '0')}m:"
          "${seconds.toString().padLeft(2, '0')}s";
    }
  }

  @override
  Widget build(BuildContext context) {
    // 市场已开盘，直接显示 child
    if (_isMarketOpen) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.71),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Market closed',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (_formattedTime case final time?) ...[
                    Dimens.vGap8,
                    Text(
                      'Reopens in: $time',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
