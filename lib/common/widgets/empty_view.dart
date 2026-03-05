import 'package:finality/common/utils/localization_extensions.dart';
import 'package:flutter/material.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Dimens.vGap16,
        Image.asset(
          Assets.commonListEmptyPic,
          width: 110,
          height: 110,
        ),
        Dimens.vGap8,
        Text(
          context.strings.message_no_records_found,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: -0.43,
          ),
        ),
        Dimens.vGap16,
      ],
    );
  }
}
