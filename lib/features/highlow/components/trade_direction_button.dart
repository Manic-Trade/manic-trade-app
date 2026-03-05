import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_svg/svg.dart';

/// HIGHER/LOWER 交易按钮
class TradeDirectionButton extends StatelessWidget {
  /// 是否是 HIGHER 按钮
  final bool isHigher;

  /// 是否正在加载
  final bool isLoading;

  /// 点击回调
  final VoidCallback? onPressed;

  const TradeDirectionButton({
    super.key,
    required this.isHigher,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        isHigher ? const Color(0xFF00D385) : const Color(0xFFFF412C);
    final shadowColor =
        isHigher ? const Color(0xFF00A669) : const Color(0xFFFF412C);
    final backgroundColor =
        isHigher ? const Color(0xFF002E1D) : const Color(0xFF481400);

    return Touchable.button(
      onTap: isLoading ? null : onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isLoading ? 0.7 : 1.0,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: Dimens.radius6,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(0, 0),
                blurRadius: 12,
                spreadRadius: 0,
                inset: true,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      isHigher
                          ? Assets.svgsIcTradingActionUp
                          : Assets.svgsIcTradingActionDown,
                      width: 20,
                      height: 20,
                    ),
                    Dimens.hGap4,
                    Text(
                      isHigher ? 'HIGHER' : 'LOWER',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ).toDrukWide(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
