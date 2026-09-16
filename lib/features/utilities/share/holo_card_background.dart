import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// ── Manic Logo SVG 路径 (48×45 viewBox，与 web 端一致) ──────────────

const String _kManicLogoSvgPath =
    'M5.20423 16.3701L0.610979 24.3234C0.272758 24.9067 0 24.8304 0 24.1599'
    'V0.327075C0 0.147184 0.147289 0 0.32731 0H47.6727C47.8527 0 48 0.147184'
    ' 48 0.327075V5.15142C48 5.20048 47.9782 5.27135 47.9564 5.31496'
    'L41.4593 16.5609C41.1865 17.0297 40.9137 16.9697 40.8483 16.4355'
    'L40.0682 9.95397C40.0518 9.82314 39.9373 9.69776 39.8063 9.6705'
    'L34.2312 8.53119C34.1057 8.50394 33.9475 8.5748 33.882 8.68928'
    'L27.1176 20.3985C26.8449 20.8674 26.5721 20.8074 26.5066 20.2732'
    'L25.7266 13.7916C25.7102 13.6608 25.5956 13.5354 25.4647 13.5082'
    'L19.8895 12.3689C19.7641 12.3416 19.6059 12.4125 19.5404 12.527'
    'L12.776 24.2362C12.5032 24.705 12.2305 24.6451 12.165 24.1108'
    'L11.3849 17.6293C11.3686 17.4985 11.254 17.3731 11.1231 17.3459'
    'L5.5479 16.2065C5.42243 16.1793 5.26423 16.2502 5.19877 16.3646'
    'L5.20423 16.3701Z'
    'M41.4865 29.0388L35.9114 27.8995C35.7859 27.8722 35.6659 27.7468'
    ' 35.6495 27.616L34.8694 21.1345C34.804 20.6002 34.5312 20.5403'
    ' 34.2584 21.0091L27.494 32.7184C27.4286 32.8328 27.2704 32.9037'
    ' 27.1449 32.8764L21.5697 31.7371C21.4443 31.7099 21.3242 31.5845'
    ' 21.3079 31.4537L20.5278 24.9721C20.4623 24.4379 20.1896 24.378'
    ' 19.9168 24.8468L13.1524 36.556C13.0869 36.6705 12.9287 36.7414'
    ' 12.8033 36.7141L7.22809 35.5748C7.10263 35.5476 6.98261 35.4222'
    ' 6.96625 35.2913L6.18616 28.8098C6.1207 28.2756 5.84794 28.2156'
    ' 5.57518 28.6844L0.0436413 38.2841C0.0218207 38.3277 0 38.3985'
    ' 0 38.4476V44.6729C0 44.8528 0.147289 45 0.32731 45H47.6727'
    'C47.8527 45 48 44.8528 48 44.6729V19.4446C48 18.7741 47.7272 18.6978'
    ' 47.389 19.281L41.8357 28.8861C41.7702 29.0006 41.612 29.0715'
    ' 41.4865 29.0442V29.0388Z';

// ── SVG path data 解析 ──────────────────────────────────────────────

Path _parseSvgPathData(String data) {
  final path = ui.Path();
  final cmdRegex = RegExp(r'([MLCHVZmlchvz])([^MLCHVZmlchvz]*)');
  double cx = 0, cy = 0;

  for (final match in cmdRegex.allMatches(data)) {
    final cmd = match.group(1)!;
    final argStr = match.group(2)!.trim();
    final args = argStr.isEmpty
        ? <double>[]
        : RegExp(r'[+-]?(?:\d+\.?\d*|\.\d+)')
            .allMatches(argStr)
            .map((m) => double.parse(m.group(0)!))
            .toList();

    switch (cmd) {
      case 'M':
        path.moveTo(args[0], args[1]);
        cx = args[0];
        cy = args[1];
        for (int i = 2; i + 1 < args.length; i += 2) {
          path.lineTo(args[i], args[i + 1]);
          cx = args[i];
          cy = args[i + 1];
        }
      case 'L':
        for (int i = 0; i + 1 < args.length; i += 2) {
          path.lineTo(args[i], args[i + 1]);
          cx = args[i];
          cy = args[i + 1];
        }
      case 'C':
        for (int i = 0; i + 5 < args.length; i += 6) {
          path.cubicTo(
            args[i],
            args[i + 1],
            args[i + 2],
            args[i + 3],
            args[i + 4],
            args[i + 5],
          );
          cx = args[i + 4];
          cy = args[i + 5];
        }
      case 'H':
        for (final x in args) {
          path.lineTo(x, cy);
          cx = x;
        }
      case 'V':
        for (final y in args) {
          path.lineTo(cx, y);
          cy = y;
        }
      case 'Z' || 'z':
        path.close();
    }
  }
  return path;
}

// ── 缓存 logo Path ─────────────────────────────────────────────────

final Path _manicLogoPath = _parseSvgPathData(_kManicLogoSvgPath);

// ── 预计算常量 ─────────────────────────────────────────────────────
const double _kInvSqrt2 = 0.7071067811865476; // 1 / sqrt(2)

// 彩虹渐变: web 端 sunpillar 颜色（紫→蓝→青→绿→黄）
final List<Color> _kRainbowColors = [
  HSLColor.fromAHSL(1, 283, 1.0, 0.80).toColor(), // 紫
  HSLColor.fromAHSL(1, 228, 1.0, 0.81).toColor(), // 蓝
  HSLColor.fromAHSL(1, 176, 1.0, 0.70).toColor(), // 青
  HSLColor.fromAHSL(1, 93, 1.0, 0.67).toColor(), // 绿
  HSLColor.fromAHSL(1, 53, 1.0, 0.67).toColor(), // 黄
];

const List<double> _kRainbowStops = [0.0, 0.25, 0.5, 0.75, 1.0];

// ── 扫描光线色（-45° 重复亮线，web 端 background-size: 300%）──────────

// 扫描光线用纯灰度，通过 multiply 混合只控制亮度，确保光线笔直均匀
const Color _kSparkleBlack = Color(0xFF111111); // ~6.8% 基底
const Color _kSparkleGray1 = Color(0xFFBBBBBB); // ~73% 光晕
const Color _kSparkleGray2 = Color(0xFFD1D1D1); // ~81.8% 亮峰（光晕+8.8%）

const List<Color> _sparkleColors = [
  _kSparkleBlack, // 0%
  _kSparkleGray1, // 3.8%
  _kSparkleGray2, // 4.5%
  _kSparkleGray1, // 5.2%
  _kSparkleBlack, // 10%
  _kSparkleBlack, // 12% (周期结束)
];

const List<double> _sparkleStops = [
  0.0,
  3.8 / 12.0, // 光晕开始
  4.5 / 12.0, // 亮峰中心
  6.2 / 12.0, // 光晕消退
  10.0 / 12.0,
  1.0,
];

// ═══════════════════════════════════════════════════════════════════
//  HoloCardBackground — 全息卡片背景效果
//
//  分层（从底到顶）：
//    1. pc-inside — 带色调的对角渐变底
//    2. pc-shine  — Logo tile 遮罩 × 彩虹渐变 × color-dodge 动画
// ═══════════════════════════════════════════════════════════════════

class HoloCardBackground extends StatefulWidget {
  /// 主题色调（用于 pc-inside 内渐变）
  final Color accentColor;
  final Color backgroundColor;

  const HoloCardBackground({
    super.key,
    required this.accentColor,
    required this.backgroundColor,
  });

  @override
  State<HoloCardBackground> createState() => _HoloCardBackgroundState();
}

class _HoloCardBackgroundState extends State<HoloCardBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ui.Image? _tileImage;
  ImageShader? _tileShader;
  double _tileScale = 1.0;
  Color _blendedAccent = const Color(0x00000000);

  Color _computeBlendedAccent() => Color.alphaBlend(
        widget.accentColor.withValues(alpha: 0.08),
        widget.backgroundColor,
      );

  @override
  void initState() {
    _blendedAccent = _computeBlendedAccent();
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant HoloCardBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accentColor != widget.accentColor ||
        oldWidget.backgroundColor != widget.backgroundColor) {
      _blendedAccent = _computeBlendedAccent();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dpr = MediaQuery.devicePixelRatioOf(context);
    if (_tileImage == null || _tileScale != dpr) {
      _tileScale = dpr;
      _buildTileImage(dpr);
    }
  }

  /// 预渲染单个 tile，按 devicePixelRatio 缩放以消除锯齿
  Future<void> _buildTileImage(double scale) async {
    const w = 70.0, h = 66.0;
    final recorder = ui.PictureRecorder();
    final c = Canvas(recorder, Rect.fromLTWH(0, 0, w * scale, h * scale));
    c.scale(scale);
    c.drawPath(
      _manicLogoPath.shift(const Offset(11, 10.5)),
      Paint()
        ..color = Colors.white
        ..isAntiAlias = false,
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage((w * scale).ceil(), (h * scale).ceil());
    if (mounted) {
      setState(() {
        _tileImage = image;
        _tileShader = _buildTileShader(image, scale);
      });
    }
  }

  ImageShader _buildTileShader(ui.Image image, double scale) {
    final s = 1.0 / scale;
    final tileMatrix = Matrix4.rotationZ(-math.pi / 4)
      ..multiply(Matrix4.diagonal3Values(s, s, 1.0));
    return ImageShader(
      image,
      TileMode.repeated,
      TileMode.repeated,
      tileMatrix.storage,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _tileImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _HoloCardPainter(
            progress: _controller.value,
            blendedAccent: _blendedAccent,
            backgroundColor: widget.backgroundColor,
            tileShader: _tileShader,
          ),
        );
      },
    );
  }
}

// ── CustomPainter ───────────────────────────────────────────────────

class _HoloCardPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color blendedAccent;
  final ImageShader? tileShader;

  _HoloCardPainter({
    required this.progress,
    required this.backgroundColor,
    required this.blendedAccent,
    this.tileShader,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // ── Layer 1: pc-inside — 基底色 + 内背景渐变 ──
    canvas.drawRect(rect, Paint()..color = backgroundColor);

    final innerShader = ui.Gradient.linear(
      Offset(size.width * 0.15, 0),
      Offset(size.width * 0.85, size.height),
      [blendedAccent, const Color(0xF2040404)],
      [0.0, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = innerShader);

    // ── Layer 2: pc-shine — 全息光效 ──
    if (tileShader == null) return;

    final diagonal =
        math.sqrt(size.width * size.width + size.height * size.height);

    final rainbowShader = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, size.height),
      _kRainbowColors,
      _kRainbowStops,
    );

    // 扫描光线: 重复的 -45° 细亮线（web: period=12%, background-size=300% → 有效周期=36%）
    final sparklePeriod = diagonal * 0.36;
    final sparkleD = sparklePeriod * _kInvSqrt2;
    // 动画: 亮线沿 -45° 方向滑动，移动整数倍周期确保无缝循环
    final sparkleOffset = progress * sparklePeriod * 3 * _kInvSqrt2;
    final sparkleShader = ui.Gradient.linear(
      Offset(size.width - sparkleOffset, size.height - sparkleOffset),
      Offset(
        size.width - sparkleOffset - sparkleD,
        size.height - sparkleOffset - sparkleD,
      ),
      _sparkleColors,
      _sparkleStops,
      TileMode.repeated,
    );

    // 组合绘制: colorDodge + contrast/saturate 滤镜 + opacity
    canvas.saveLayer(
      rect,
      Paint()
        ..blendMode = BlendMode.colorDodge
        ..colorFilter = const ui.ColorFilter.matrix(<double>[
          // CSS: filter: contrast(1.5) saturate(0.7); opacity: 0.65
          // = Saturate(0.7, Rec.709) × Contrast(1.5), alpha ×0.65
          1.14567, 0.32184, 0.03249, 0, -63.75,
          0.09567, 1.37184, 0.03249, 0, -63.75,
          0.09567, 0.32184, 1.08249, 0, -63.75,
          0, 0, 0, 0.65, 0,
        ]),
    );

    // 子层: 彩虹底色 × 灰度光线（multiply = 光线控制亮度，彩虹提供颜色）
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(rect, Paint()..shader = rainbowShader);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = sparkleShader
        ..blendMode = BlendMode.multiply,
    );
    canvas.restore();

    // Tile 遮罩: 只在 logo 形状区域显示（dstIn 保留目标中与源重叠的部分）
    canvas.drawRect(
      rect,
      Paint()
        ..shader = tileShader
        ..blendMode = BlendMode.dstIn,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_HoloCardPainter old) =>
      old.progress != progress ||
      old.tileShader != tileShader;
}
