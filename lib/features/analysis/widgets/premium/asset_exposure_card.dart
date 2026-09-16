import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/dimens.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// 资产颜色映射（与 Web 端 ASSET_COLOR_MAP 一致）
const _assetColorMap = <String, Color>{
  'BTC': Color(0xFFFF9900),
  'SOL': Color(0xFFA855F7),
  'ETH': Color(0xFF3B82F6),
};

/// 未映射资产的备用色板（与 Web 端 DONUT_FALLBACK_COLORS 一致）
const _fallbackColors = [
  Color(0xFF00D385),
  Color(0xFFFF412C),
  Color(0xFFFFCC80),
  Color(0xFF06B6D4),
  Color(0xFFF97316),
];

/// 资产分布卡片 — 甜甜圈图 + 图例列表
///
/// 使用 fl_chart PieChart 实现，对齐 Web 端 recharts 效果：
/// - innerRadius=62, outerRadius=82, paddingAngle=3, cornerRadius 圆角
/// - 选中段高亮 + 光晕，未选中段变淡
/// - 中心叠加 Widget：默认显示总交易量，选中时显示资产详情
class AssetExposureCard extends StatefulWidget {
  final List<AssetBreakdownVO> assets;

  const AssetExposureCard({super.key, required this.assets});

  @override
  State<AssetExposureCard> createState() => _AssetExposureCardState();
}

class _AssetExposureCardState extends State<AssetExposureCard> {
  int? _selectedIndex;

  /// 为每个资产分配颜色（含 fallback 计数器）
  late List<Color> _colors = _buildColors();

  List<Color> _buildColors() {
    int fallbackIdx = 0;
    return widget.assets.map((a) {
      final mapped = _assetColorMap[a.asset.toUpperCase()];
      if (mapped != null) return mapped;
      return _fallbackColors[fallbackIdx++ % _fallbackColors.length];
    }).toList();
  }

  @override
  void didUpdateWidget(covariant AssetExposureCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assets != widget.assets) {
      _selectedIndex = null;
      _colors = _buildColors();
    }
  }

  void _onTapSegment(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assets.isEmpty) return const SizedBox.shrink();

    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          _buildHeader(),
          Dimens.vGap12,
          _buildDonut(),
          Dimens.vGap16,
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ASSET EXPOSURE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 0.8,
              height: 21 / 14,
            ),
          ),
          Dimens.vGap4,
          Text(
            _selectedIndex != null
                ? '${widget.assets[_selectedIndex!].asset} focused'
                : 'Trade volume share by asset',
            style: TextStyle(
          fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kPremiumOrange.withValues(alpha: 0.3),
                height: 18 / 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 甜甜圈图区域 — fl_chart PieChart + 中心 Widget 叠加
  Widget _buildDonut() {
    const donutSize = 185.0;
    const innerR = 62.0;
    const ringWidth = 20.0; // outerR(82) - innerR(62)

    return SizedBox(
      width: donutSize,
      height: donutSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // CRT 光晕背景
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kPremiumOrange.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.3, 0.7],
                ),
              ),
            ),
          ),
          // 饼图
          PieChart(
            PieChartData(
              sections: _buildSections(ringWidth),
              sectionsSpace: 3,
              centerSpaceRadius: innerR,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (event is FlTapUpEvent) {
                    final idx = response?.touchedSection?.touchedSectionIndex;
                    if (idx != null && idx >= 0) {
                      _onTapSegment(idx);
                    } else {
                      // 点击中心空白区域
                      if (_selectedIndex != null) {
                        setState(() => _selectedIndex = null);
                      }
                    }
                  }
                },
              ),
              borderData: FlBorderData(show: false),
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          ),
          // CRT 扫描线覆盖在甜甜圈上
          IgnorePointer(
            child: SizedBox(
              width: donutSize,
              height: donutSize,
              child: ClipOval(
                child: CustomPaint(
                  painter: const _ScanLinesPainter(),
                ),
              ),
            ),
          ),
          // 中心内容
          IgnorePointer(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: _buildCenterContent(),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double ringWidth) {
    return List.generate(widget.assets.length, (i) {
      final asset = widget.assets[i];
      final color = _colors[i];
      final isActive = _selectedIndex == i;
      final isDimmed = _selectedIndex != null && _selectedIndex != i;

      return PieChartSectionData(
        value: asset.share.toDouble(),
        color: isDimmed ? color.withValues(alpha: 0.25) : color,
        radius: isActive ? ringWidth + 4 : ringWidth,
        showTitle: false,
        borderSide: isActive
            ? BorderSide(
                color: color.withValues(alpha: 0.6),
                width: 1.5,
              )
            : BorderSide.none,
      );
    });
  }

  /// 中心内容：选中时显示资产详情，默认显示总交易量
  Widget _buildCenterContent() {
    if (_selectedIndex != null) {
      final asset = widget.assets[_selectedIndex!];
      final color = _colors[_selectedIndex!];
      return _SelectedAssetCenter(
        key: ValueKey('selected_$_selectedIndex'),
        asset: asset,
        color: color,
      );
    }

    final totalVolume = widget.assets.fold<double>(0, (s, a) => s + a.volume);
    return _DefaultCenter(
      key: const ValueKey('default'),
      totalVolume: totalVolume,
    );
  }

  /// 图例列表
  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: List.generate(widget.assets.length, (i) {
        final asset = widget.assets[i];
        final color = _colors[i];
        final isActive = _selectedIndex == i;
        final isDimmed = _selectedIndex != null && _selectedIndex != i;

        return GestureDetector(
          onTap: () => _onTapSegment(i),
          child: AnimatedOpacity(
            opacity: isDimmed ? 0.35 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              constraints: const BoxConstraints(minWidth: 72),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isActive
                    ? color.withValues(alpha: 0.08)
                    : Colors.transparent,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            color: color.withValues(alpha: 0.12),
                            blurRadius: 12)
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 色圆点
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 9 : 8,
                    height: isActive ? 9 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: isActive ? 0.6 : 0.3),
                          blurRadius: isActive ? 8 : 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // 资产名
                  Text(
                    asset.asset.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // 占比
                  Text(
                    '${asset.share}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// 选中资产时的中心内容：资产名 + 胜率 + 详情网格
class _SelectedAssetCenter extends StatelessWidget {
  final AssetBreakdownVO asset;
  final Color color;

  const _SelectedAssetCenter({
    super.key,
    required this.asset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = asset.netPnl >= 0;
    final pnlColor = isPositive ? kPremiumGreen : kPremiumRed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 资产名
        Text(
          asset.asset.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.0,
            color: Colors.white.withValues(alpha: 0.9),
            shadows: [
              Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8)
            ],
          ).toDrukWide(),
        ),
        const SizedBox(height: 4),
        // 胜率
        Text(
          '${asset.winRate}%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.0,
            color: const Color(0xFFFFCC80),
            shadows: [
              Shadow(
                  color: kPremiumOrange.withValues(alpha: 0.5), blurRadius: 6),
            ],
          ).toDrukWide(),
        ),
        const SizedBox(height: 2),
        Text(
          'WIN RATE',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.25),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        // 详情网格：Trades / Volume / Net P&L
        _detailGrid(isPositive, pnlColor),
      ],
    );
  }

  Widget _detailGrid(bool isPositive, Color pnlColor) {
    final items = [
      ('Trades', '${asset.trades}', Colors.white.withValues(alpha: 0.5)),
      (
        'Volume',
        '\$${_compactNumber(asset.volume)}',
        Colors.white.withValues(alpha: 0.5)
      ),
      (
        'Net P&L',
        '${isPositive ? "+" : ""}\$${_compactNumber(asset.netPnl.abs())}',
        pnlColor
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.$1,
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.$2,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: item.$3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// 默认中心内容：总交易量
class _DefaultCenter extends StatelessWidget {
  final double totalVolume;

  const _DefaultCenter({super.key, required this.totalVolume});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\$${_compactNumber(totalVolume)}',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.0,
            color: const Color(0xFFFFCC80),
            shadows: [
              Shadow(
                  color: kPremiumOrange.withValues(alpha: 0.5), blurRadius: 8),
            ],
          ).toDrukWide(),
        ),
        const SizedBox(height: 4),
        Text(
          'TOTAL VOLUME',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: kPremiumOrange.withValues(alpha: 0.3),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

/// CRT 扫描线覆盖
class _ScanLinesPainter extends CustomPainter {
  const _ScanLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 2.0;
    final paint = Paint()
      ..color = const Color(0x26000000) // rgba(0,0,0,0.15)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _compactNumber(double value) {
  if (value.abs() >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
  if (value.abs() >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
  return value.toStringAsFixed(0);
}
