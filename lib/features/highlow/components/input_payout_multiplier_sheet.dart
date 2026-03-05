import 'package:collection/collection.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/highlow/config/high_low_settings_store.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

/// 倍率模式枚举
enum MultiplierMode {
  classic(
    quickSelectValues: [1.2, 1.5, 2.0, 3.0],
    minValue: 1.0,
    maxValue: 3.0,
    color: Color(0xFFDBC100),
    label: 'Classic',
    modeTitle: 'Classic Mode',
    iconAssetName: Assets.svgsIcPayoutMultiplierClassic,
  ),
  pro(
    quickSelectValues: [3.0, 5.0, 10.0, 20.0],
    minValue: 1.0,
    maxValue: 20.0,
    color: Color(0xFFDB8300),
    label: 'Pro',
    modeTitle: 'Pro Mode',
    iconAssetName: Assets.svgsIcPayoutMultiplierPro,
  ),
  manic(
    quickSelectValues: [15.0, 30.0, 50.0, 100.0],
    minValue: 1.0,
    maxValue: 100.0,
    color: Color(0xFFDB4500),
    label: 'Manic',
    modeTitle: 'Manic Mode',
    iconAssetName: Assets.svgsIcPayoutMultiplierManic,
  );

  final List<double> quickSelectValues;
  final double minValue;
  final double maxValue;
  final Color color;
  final String label;
  final String modeTitle;
  final String iconAssetName;

  const MultiplierMode({
    required this.quickSelectValues,
    required this.minValue,
    required this.maxValue,
    required this.color,
    required this.label,
    required this.modeTitle,
    required this.iconAssetName,
  });
}

class InputPayoutMultiplierSheet extends StatefulWidget {
  final double initialPayoutMultiplier;
  final MultiplierMode initialMode;
  final double leverageMax;

  const InputPayoutMultiplierSheet({
    super.key,
    required this.initialPayoutMultiplier,
    required this.initialMode,
    required this.leverageMax,
  });

  @override
  State<InputPayoutMultiplierSheet> createState() =>
      _InputPayoutMultiplierSheetState();
}

class _InputPayoutMultiplierSheetState
    extends State<InputPayoutMultiplierSheet> {
  late double _currentMultiplier;
  late MultiplierMode _currentMode;
  late final HighLowSettingsStore _settingsStore = injector<HighLowSettingsStore>();
  late final double _leverageMax;
  late final List<MultiplierMode> _availableModes;

  @override
  void initState() {
    super.initState();
    _leverageMax = widget.leverageMax.clamp(1.0, 100.0);
    _availableModes = _computeAvailableModes(_leverageMax);
    _currentMode = _availableModes.contains(widget.initialMode)
        ? widget.initialMode
        : _availableModes.last;
    _currentMultiplier = widget.initialPayoutMultiplier.clamp(
      _currentMode.minValue,
      _effectiveMaxValue(_currentMode),
    );
  }

  double _effectiveMaxValue(MultiplierMode mode) {
    return mode.maxValue > _leverageMax ? _leverageMax : mode.maxValue;
  }

  static List<MultiplierMode> _computeAvailableModes(double leverageMax) {
    final available = <MultiplierMode>[];
    for (final mode in MultiplierMode.values) {
      available.add(mode);
      if (mode.maxValue >= leverageMax) break;
    }
    return available;
  }

  void _updateMode(MultiplierMode mode) {
    if (mode == _currentMode) {
      return;
    }
    if (_currentMultiplier < mode.minValue) {
      _currentMultiplier = mode.minValue;
    }
    final effectiveMax = _effectiveMaxValue(mode);
    if (_currentMultiplier > effectiveMax) {
      _currentMultiplier = effectiveMax;
    }
    _currentMode = mode;
    _settingsStore.seMultiplierMode(mode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DragHandle(),
            Padding(
              padding: Dimens.edgeInsetsA16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payout Multiplier',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.appColors.bottomSheetTitle,
                    ),
                  ),
                  Dimens.vGap40,
                  _buildMultiplierCard(context),
                  Dimens.vGap32,
                  _buildButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiplierCard(BuildContext context) {
    return Container(
      padding: Dimens.edgeInsetsA16,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Multiplier Mode",
            style: context.textTheme.labelSmall?.copyWith(
              color: context.textColorTheme.textColorHelper,
            ),
          ),
          Dimens.vGap2,
          Row(
            children: [
              _buildProModeSelector(context),
              Spacer(),
              Text(
                '${_currentMultiplier.toStringAsFixed(1)}x',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  color: _currentMode.color,
                  height: 1,
                ),
              ),
            ],
          ),
          Dimens.vGap32,
          _buildSlider(context),
          Dimens.vGap24,
          _buildQuickSelectButtons(context),
        ],
      ),
    );
  }

  Widget _buildProModeSelector(BuildContext context) {
    final hasMultipleModes = _availableModes.length > 1;

    final label = SizedBox(
      height: 38,
      child: Column(
        children: [
          Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                _currentMode.iconAssetName,
                width: 12,
                height: 12,
              ),
              Dimens.hGap4,
              Text(
                _currentMode.modeTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _currentMode.color,
                ),
              ),
              if (hasMultipleModes) ...[
                Dimens.hGap8,
                SvgPicture.asset(
                  Assets.svgsIcArrowDownMultiplierMode,
                  width: 8,
                  height: 8,
                ),
              ],
            ],
          ),
          SizedBox(height: 3),
        ],
      ),
    );

    if (!hasMultipleModes) return label;

    return PopupMenuButton<MultiplierMode>(
      tooltip: '',
      elevation: 16,
      onSelected: (mode) {
        HapticFeedbackUtils.selectionClick();
        _updateMode(mode);
      },
      onOpened: () {
        HapticFeedbackUtils.lightImpact();
      },
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 120,
      ),
      offset: const Offset(0, 44),
      color: context.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: context.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      itemBuilder: (context) => _availableModes.map((mode) {
        final isSelected = mode == _currentMode;
        return PopupMenuItem<MultiplierMode>(
          value: mode,
          height: 40,
          padding: EdgeInsets.zero,
          child: Touchable.button(
            child: Container(
              height: 40,
              width: 120,
              color: isSelected
                  ? context.colorScheme.outlineVariant
                  : Colors.transparent,
              padding: Dimens.edgeInsetsH16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    mode.iconAssetName,
                    width: 12,
                    height: 12,
                  ),
                  Dimens.hGap4,
                  Text(
                    mode.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? context.textColorTheme.textColorPrimary
                          : context.textColorTheme.textColorTertiary,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
      child: Touchable.button(child: label),
    );
  }

  Widget _buildSlider(BuildContext context) {
    final glowColor = _currentMode.color;
    final effectiveMax = _effectiveMaxValue(_currentMode);
    final range = effectiveMax - _currentMode.minValue;
    final sliderDivisions = range > 0 ? (range / 0.1).round() : 1;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2,
        activeTrackColor: glowColor,
        inactiveTrackColor: Color(0xFF222222),
        thumbColor: const Color(0xFF222222),
        thumbShape: _CustomThumbShape(
          borderColor: glowColor,
        ),
        overlayColor: Colors.transparent,
        overlayShape: SliderComponentShape.noOverlay,
        tickMarkShape: SliderTickMarkShape.noTickMark,
        trackShape: _GlowingSliderTrackShape(
          glowColor: glowColor,
          glowRadius: 2,
        ),
      ),
      child: Slider(
        padding: EdgeInsets.zero,
        value: _currentMultiplier,
        min: _currentMode.minValue,
        max: effectiveMax,
        divisions: sliderDivisions,
        onChanged: (value) {
          HapticFeedbackUtils.vibrate(HapticsType.soft);
          setState(() {
            _currentMultiplier = value;
          });
        },
      ),
    );
  }

  Widget _buildQuickSelectButtons(BuildContext context) {
    List<Widget> rowChildren = [];
    _currentMode.quickSelectValues.forEachIndexed((index, value) {
      final isSelected = _currentMultiplier == value;
      final isDisabled = value > _leverageMax;
      final button = Touchable.plain(
        onTap: () {
          setState(() {
            _currentMultiplier = value;
          });
        },
        child: Container(
          height: 36,
          constraints: BoxConstraints(minWidth: 56, maxWidth: 64),
          decoration: BoxDecoration(
            color: isSelected && !isDisabled
                ? context.colorScheme.outlineVariant
                : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Text(
              '${value.toStringAsFixed(1)}x',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDisabled
                    ? context.textColorTheme.textColorQuaternary
                        .withValues(alpha: 0.3)
                    : isSelected
                        ? context.colorScheme.primary
                        : context.textColorTheme.textColorQuaternary,
              ),
            ),
          ),
        ),
      );
      rowChildren.add(
        isDisabled ? IgnorePointer(child: button) : button,
      );
      if (index != _currentMode.quickSelectValues.length - 1) {
        rowChildren
            .add(Expanded(child: Center(child: const SizedBox(width: 12))));
      }
    });
    return Row(
      children: rowChildren,
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Touchable.plain(
          onTap: () {
            // Navigator.of(context).pop(_currentMode.minValue);
            setState(() {
              _currentMultiplier = _currentMode.minValue;
            });
          },
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: context.colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  'Reset',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.textColorTheme.textColorTertiary,
                  ),
                ),
              ),
            ),
          ),
        )),
        Dimens.hGap16,
        Expanded(
            child: Touchable.plain(
          onTap: () {
            Navigator.of(context).pop(_currentMultiplier);
          },
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: context.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  'Confirm',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }
}

/// 自定义带阴影发光效果的滑块轨道
class _GlowingSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  final Color glowColor;
  final double glowRadius;

  const _GlowingSliderTrackShape({
    required this.glowColor,
    required this.glowRadius,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final double trackHeight = sliderTheme.trackHeight ?? 2;
    final double trackRadius = trackHeight / 2;
    final Canvas canvas = context.canvas;

    // 绘制非激活轨道（右侧灰色部分）
    final inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? Colors.grey
      ..style = PaintingStyle.fill;

    final inactiveTrackRRect = RRect.fromLTRBR(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
      Radius.circular(trackRadius),
    );
    canvas.drawRRect(inactiveTrackRRect, inactivePaint);

    // 绘制激活轨道的阴影发光效果
    final glowPaint = Paint()
      ..color = glowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);

    final activeTrackRRect = RRect.fromLTRBR(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
      Radius.circular(trackRadius),
    );
    canvas.drawRRect(activeTrackRRect, glowPaint);

    // 绘制激活轨道（左侧黄色部分）
    final activePaint = Paint()
      ..color = sliderTheme.activeTrackColor ?? glowColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(activeTrackRRect, activePaint);
  }
}

/// 自定义滑块圆点样式
/// background: #222222
/// border: 1px solid #DB8300
/// box-shadow: 0px 4px 6px -4px #0000001A, 0px 10px 15px -3px #0000001A
/// size: 14.5px (radius ~7.25)
class _CustomThumbShape extends SliderComponentShape {
  final Color borderColor;

  // 14.5px / 2 = 7.25
  static const double _thumbRadius = 7.25;

  const _CustomThumbShape({
    required this.borderColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(_thumbRadius + 1);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // 绘制阴影1: 0px 10px 15px -3px #0000001A
    final shadow1Paint = Paint()
      ..color = const Color(0x1A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.5);
    canvas.drawCircle(center.translate(0, 5), _thumbRadius, shadow1Paint);

    // 绘制阴影2: 0px 4px 6px -4px #0000001A
    final shadow2Paint = Paint()
      ..color = const Color(0x1A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center.translate(0, 2), _thumbRadius, shadow2Paint);

    // 绘制边框 (1px solid #DB8300)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, _thumbRadius, borderPaint);

    // 绘制内圈填充 (background: #222222)
    final thumbPaint = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, _thumbRadius - 0.5, thumbPaint);

    // 绘制中心小圆点 (4x4, background: #DB8300)
    final centerDotPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2, centerDotPaint);
  }
}

/// 显示 Payout Multiplier 选择底部弹窗
Future<double?> showPayoutMultiplierSheet(
  BuildContext context, {
  required double initialPayoutMultiplier,
  required double leverageMax,
  MultiplierMode? initialMode,
}) {
  final clampedLeverageMax = leverageMax.clamp(1.0, 100.0);

  // Compute available modes based on leverageMax
  final availableModes = <MultiplierMode>[];
  for (final m in MultiplierMode.values) {
    availableModes.add(m);
    if (m.maxValue >= clampedLeverageMax) break;
  }

  MultiplierMode mode = initialMode ?? injector<HighLowSettingsStore>().getMultiplierMode();

  // Auto-downgrade mode if not available
  if (!availableModes.contains(mode)) {
    mode = availableModes.last;
  }

  // If current multiplier exceeds mode's max, find a bigger available mode
  if (initialPayoutMultiplier > mode.maxValue) {
    mode = availableModes.firstWhere(
      (element) => element.maxValue >= initialPayoutMultiplier,
      orElse: () => availableModes.last,
    );
  }

  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    constraints: null,
    backgroundColor: Colors.transparent,
    builder: (_) => InputPayoutMultiplierSheet(
      initialPayoutMultiplier: initialPayoutMultiplier,
      initialMode: mode,
      leverageMax: clampedLeverageMax,
    ),
  );
}
