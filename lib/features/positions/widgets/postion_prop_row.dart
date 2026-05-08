import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';

class PostionPropRow extends StatelessWidget {
  final String title;
  final String? value;
  final Widget? trailing;
  const PostionPropRow({
    super.key,
    required this.title,
    this.value,
    this.trailing,
  }) : assert((value == null) != (trailing == null),
            'value 和 trailing 必须恰好设置一个，不能都为空或都设置');

  /// 获取 value 的默认文本样式，可用于自定义 trailing
  static TextStyle valueTextStyle(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color ?? context.textColorTheme.textColorSecondary,
      height: 1.2142,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.textColorTheme.textColorQuaternary,
            height: 1.25,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (value != null)
          Text(
            value!,
            style: valueTextStyle(context),
          ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
