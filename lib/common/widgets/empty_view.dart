import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../generated/assets.dart';
import '../../theme/dimens.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.center = true});

  final bool center;

  @override
  Widget build(BuildContext context) {
    if (center) {
      return _buildContent(context);
    } else {
      return _buildConstrainedBox(context, _buildContent(context));
    }
  }

  _buildConstrainedBox(BuildContext context, Widget child) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: child,
        ),
      ],
    );
  }

  _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Dimens.vGap4,
          // 图标
          SvgPicture.asset(
            Assets.svgsEmptyPositionsPic,
            width: 40,
            height: 40,
            color: context.textColorTheme.textColorHelper,
          ),
          Dimens.vGap8,

          Text(
            context.strings.message_no_records_found,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.2142,
              color: context.textColorTheme.textColorHelper,
            ),
          ),
          Dimens.vGap16,
        ],
      ),
    );
  }
}
