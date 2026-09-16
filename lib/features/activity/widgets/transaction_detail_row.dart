import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/theme/dimens.dart';

class TransactionDetailRow extends StatelessWidget {
  /// Row的标题图标
  final String svgIconAssetName;

  /// Row的标题文字
  final String label;

  /// 是否是偶数行，用于控制背景色
  final bool isEven;

  /// 右侧详情文字，与detailWidget互斥，优先显示detailWidget
  final String? detail;

  /// 详情文字颜色
  final Color? detailColor;

  /// 右侧自定义Widget，将替换detail文字
  final Widget? detailWidget;

  /// 点击事件回调
  final VoidCallback? onTap;

  /// 自定义背景色，覆盖默认的交替背景色
  final Color? backgroundColor;

  /// 左侧图标颜色
  final Color? iconColor;

  /// 标题文字样式
  final TextStyle? labelStyle;

  /// 详情文字样式，当detail不为空时生效
  final TextStyle? detailStyle;

  /// 内容边距
  final EdgeInsetsGeometry? padding;

  const TransactionDetailRow({
    super.key,
    required this.svgIconAssetName,
    required this.label,
    required this.isEven,
    this.detail,
    this.detailColor,
    this.detailWidget,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.labelStyle,
    this.detailStyle,
    this.padding,
  }) : assert(
          detail == null || detailWidget == null,
          'Cannot provide both detail and detailWidget',
        );

  @override
  Widget build(BuildContext context) {
    // 构建右侧内容
    Widget? trailingWidget;
    if (detailWidget != null) {
      trailingWidget = detailWidget;
    } else if (detail != null) {
      trailingWidget = Text(
        detail!,
        style: detailStyle ??
            TextStyle(
              color: detailColor ?? context.textColorTheme.textColorPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
      );
    }

    var labelColor = context.textColorTheme.textColorSecondary;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isEven
                ? context.colorScheme.surfaceContainerHighest
                : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Touchable(
        onTap: onTap,
        child: Padding(
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Center(
                  child: SvgPicture.asset(svgIconAssetName,
                      width: 20, height: 20, color: labelColor),
                ),
              ),
              Dimens.hGap6,
              Expanded(
                child: Text(
                  label,
                  style: labelStyle ??
                      TextStyle(
                        color: labelColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
              ),
              if (trailingWidget != null) trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}
