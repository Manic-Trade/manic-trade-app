import 'dart:async';

import 'package:finality/common/constants/app_links.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/features/login/widgets/top_logo_on_logo.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

/// 「关注 @ManicTrade」弱提示弹窗
///
/// 触发：使用 X 登录的新用户首次完成 `_checkUser` 后。返回用户、Google/Apple
/// 登录、邀请页主动绑定 X 都不弹（与 web 的 `loginFollowX` modal 触发条件一致）。
///
/// 交互：点 Follow on X 跳浏览器并 1.5s 后自动关闭；用户也可以从右上角 X 直接
/// 跳过——是软引导而不是阻塞步骤。
Future<void> showFollowXDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => const _FollowXDialog(),
  );
}

class _FollowXDialog extends StatefulWidget {
  const _FollowXDialog();

  @override
  State<_FollowXDialog> createState() => _FollowXDialogState();
}

class _FollowXDialogState extends State<_FollowXDialog> {
  Timer? _autoCloseTimer;
  // 防止 follow 跳转后 timer 与用户手动关闭重复 pop。
  bool _dismissed = false;

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  void _close() {
    if (_dismissed) return;
    _dismissed = true;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _onFollowTap() async {
    await launchUrl(
      Uri.parse(AppLinks.urlFollowManicTradeOnX),
      mode: LaunchMode.externalApplication,
    );
    // 浏览器拉起后乐观地把弹窗关掉，让用户回到 app 直接进入主页面，不强行
    // 校验是否真的点了关注（与 web 的乐观推进 1.5s 行为一致）。
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(const Duration(milliseconds: 1500), _close);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final textColorTheme = context.textColorTheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // 与 web `max-w-[calc(100%-2rem)]` 等价：左右各留 16，移动端撑满。
      insetPadding: Dimens.edgeInsetsScreenH,
      child: ConstrainedBox(
        // 与 web `sm:max-w-[432px]` 对齐。
        constraints: const BoxConstraints(maxWidth: 432),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
            borderRadius: Dimens.radius12,
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                offset: Offset(0, 20),
                blurRadius: 25,
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Color(0xB3000000),
                offset: Offset(0, 8),
                blurRadius: 10,
                spreadRadius: -6,
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                // web 用 p-10 = 40。
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TopLogoOnLogo(
                      size: 48,
                      child: SvgPicture.asset(
                        Assets.svgsIcLinkTwitter,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    // web gap-8 = 32。
                    Dimens.vGap32,
                    Text(
                      'FOLLOW @${AppLinks.xManicTradeHandle.toUpperCase()}',
                      textAlign: TextAlign.center,
                      style: DrukWideFont.textStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColorTheme.textColorPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    // web 标题/描述 gap-2 = 8。
                    Dimens.vGap8,
                    Text(
                      'Follow our official X account to complete the login process.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: textColorTheme.textColorTertiary,
                      ),
                    ),
                    Dimens.vGap32,
                    Touchable.button(
                      onTap: _onFollowTap,
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: Dimens.radius4,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'FOLLOW ON X',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    // web 按钮/hint gap-4 = 16。
                    Dimens.vGap16,
                    Text(
                      'Click follow on X, then return to the app to continue.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: textColorTheme.textColorPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // web `top-5 right-5` + `size-4`：icon 中心距卡片右/上 28。
              // 这里 Positioned 12 + 内 padding 8 + icon 8 半径 = 28，热区 32×32。
              Positioned(
                top: 12,
                right: 12,
                child: Touchable.iconButton(
                  onTap: _close,
                  child: Padding(
                    padding: Dimens.edgeInsetsA8,
                    child: Icon(
                      RemixIcons.close_line,
                      size: 16,
                      color: textColorTheme.textColorTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
