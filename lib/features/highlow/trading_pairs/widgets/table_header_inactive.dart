import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

class TableHeaderInactive extends StatelessWidget {
  final int inactiveAssetsCount;
  const TableHeaderInactive({super.key, required this.inactiveAssetsCount});

  @override
  Widget build(BuildContext context) {
   
    return Container(
          padding: Dimens.edgeInsetsH16,
          height: 32,
          color: context.colorScheme.surfaceContainerLow,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Inactive Assets',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.textColorTheme.textColorHelper,
                ),
              ),
              Dimens.hGap8,
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2.34),
                ),
                child: Center(
                  child: Text(
                    '$inactiveAssetsCount',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: context.textColorTheme.textColorQuaternary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
