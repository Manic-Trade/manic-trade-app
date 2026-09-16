import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// USDC 圆形状态图标
/// [processing] 显示加载圈，[showCheck] 右下角显示绿色对勾
class UsdcStatusIcon extends StatelessWidget {
  final bool showCheck;
  final bool processing;

  const UsdcStatusIcon({
    super.key,
    required this.showCheck,
    required this.processing,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        LogoImage(
            iconURL: Tokens.usdc.iconUrl,
            symbol: "USDC",
            width: 40,
            height: 40),
        if (showCheck)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFF00D385),
                shape: BoxShape.circle,
              ),
              child: const Icon(RemixIcons.check_line,
                  size: 10, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
