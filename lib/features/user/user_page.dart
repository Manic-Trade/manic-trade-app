import 'package:easy_refresh/easy_refresh.dart';
import 'package:finality/common/constants/app_links.dart';
import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/utils/price_format.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/data/app_preferences.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/auth/auth_session_coordinator.dart';
import 'package:finality/features/analysis/analysis_screen.dart';
import 'package:finality/features/analysis/vm/today_win_rate_vm.dart';
import 'package:finality/features/analysis/widgets/account_win_rate_card.dart';
import 'package:finality/features/deposit/deposite_sheet.dart';
import 'package:finality/features/feedback/feed_back_sheet.dart';
import 'package:finality/features/history/history_screen.dart';
import 'package:finality/features/user/user_view_model.dart';
import 'package:finality/features/user/widgets/user_menu_item.dart';
import 'package:finality/features/utilities/web/webview_screen.dart';
import 'package:finality/features/withdraw/withdraw_sheet.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:finality/features/user/widgets/real_toggle_button.dart';
import 'package:store_scope/store_scope.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with ScopedSpaceStateMixin {
  late final UserViewModel _viewModel;
  late final TodayWinRateVM _todayWinRateVM;

  @override
  void initState() {
    super.initState();
    _viewModel = space.bind(userViewModelProvider);
    _todayWinRateVM = space.bind(todayWinRateVMProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        title: _buildTotalBalanceRow(context),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return EasyRefresh(
      onRefresh: () async {
        await Future.wait([
          _viewModel.handleCallRefresh(),
          _todayWinRateVM.refresh(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildWinRateCard(),
            const Divider(),
            _buildMenuItems(context),
            Dimens.safeBottomSpace,
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalAssetValue(context),
          Dimens.vGap16,
          _buildActionButtons(context),
          Dimens.vGap24,
        ],
      ),
    );
  }

  Widget _buildTotalBalanceRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左侧：Total Balance 标题 + 邮箱副标题
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.strings.title_total_balance,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textColorTheme.textColorTertiary,
                  height: 24 / 16,
                  letterSpacing: 0.4,
                ),
              ),
              ValueListenableBuilder<String?>(
                valueListenable: _viewModel.uidText,
                builder: (context, uid, _) {
                  if (uid == null || uid.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          uid,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.textColorTheme.textColorQuaternary,
                            height: 18 / 12,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        // 右侧：Demo/Real 胶囊切换
        ValueListenableBuilder<int>(
          valueListenable: _viewModel.selectedTabIndex,
          builder: (context, selectedIndex, _) {
            return _buildDemoRealToggle(
              context,
              selectedIndex,
              (index) {
                _viewModel.setAccountType(index == 1);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDemoRealToggle(
    BuildContext context,
    int selectedIndex,
    ValueChanged<int> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xFF1F1F1F), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(context, 0, 'Demo', selectedIndex, onChanged),
          RealToggleButton(
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    int index,
    String label,
    int selectedIndex,
    ValueChanged<int> onChanged,
  ) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 86,
        height: 36,
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF2B2B2B),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: const Color(0xFF3B3B3B), width: 0.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              )
            : const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(9999)),
              ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF454545),
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalAssetValue(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: injector<AppPreferences>().amountVisibleNotifier,
      builder: (context, amountVisible, _) {
        if (!amountVisible) {
          return GestureDetector(
            onTap: () => injector<AppPreferences>().amountVisible = true,
            child: Text(
              '******',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                height: 1.21875,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }
        return ValueListenableBuilder(
          valueListenable: _viewModel.selectedTabIndex,
          builder: (context, selectedTabIndex, _) {
            final isReal = selectedTabIndex == 1;
            if (isReal) {
              return ValueListenableBuilder(
                  valueListenable: _viewModel.realBalanceState,
                  builder: (context, balanceState, _) {
                    var balanceValue = balanceState.valueOrFallback;
                    return _buildTotalBalanceValue(context, balanceValue);
                  });
            }
            // Demo tab：显示 demo 账户余额
            return ValueListenableBuilder(
              valueListenable: _viewModel.totalAssetValue,
              builder: (context, value, _) {
                return _buildTotalBalanceValue(context, value);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTotalBalanceValue(BuildContext context, double? balanceValue) {
    return GestureDetector(
      onTap: () => injector<AppPreferences>().amountVisible = false,
      child: Text(
        balanceValue == null
            ? "---"
            : balanceValue.formatPrice(currencySymbol: Currencies.symbolUsd),
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.21875,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildCircularActionButton(
          context,
          label: 'Deposit',
          svgAssetPath: Assets.svgsUserActionBtnIconDeposit,
          onPressed: () => showDepositSheet(context),
        ),
        const SizedBox(width: 24),
        _buildCircularActionButton(
          context,
          label: 'Withdraw',
          svgAssetPath: Assets.svgsUserActionBtnIconWithdraw,
          onPressed: () => showWithdrawSheet(context),
        ),
        const SizedBox(width: 24),
        _buildCircularActionButton(
          context,
          label: 'History',
          svgAssetPath: Assets.svgsUserWalletHistoryIcon,
          onPressed: () {
            Get.to(() => HistoryScreen());
          },
        ),
      ],
    );
  }

  Widget _buildCircularActionButton(
    BuildContext context, {
    required String label,
    required String svgAssetPath,
    required VoidCallback onPressed,
  }) {
    return Touchable.plain(
      onTap: onPressed,
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(color: context.colorScheme.outlineVariant),
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgAssetPath,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    context.textColorTheme.textColorPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.textColorTheme.textColorSecondary,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Win Rate Card ──────────────────────────────────────────────────────────

  Widget _buildWinRateCard() {
    return ValueListenableBuilder(
      valueListenable: _todayWinRateVM.todayWinRateState,
      builder: (context, state, _) {
        final data = state.valueOrFallback;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: AccountWinRateCard(
            data: data,
            onTap: () => Get.to(() => const AnalysisScreen()),
          ),
        );
      },
    );
  }

  // ── Menu Items ──────────────────────────────────────────────────────────────

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        UserMenuItem(
          svgAssetPath: Assets.svgsUserMenuFeedback,
          title: 'Feedback',
          onTap: () {
            showFeedBackSheet(context);
          },
        ),
        const Divider(),
        UserMenuItem(
          svgAssetPath: Assets.svgsUserMenuTermsOfService,
          title: 'Terms of Service',
          onTap: () {
            openWeb(AppLinks.urlTermsOfUse);
          },
        ),
        UserMenuItem(
          svgAssetPath: Assets.svgsUserMenuPrivacyPolicy,
          title: 'Privacy Policy',
          onTap: () {
            openWeb(AppLinks.urlPrivacy);
          },
        ),
        UserMenuItem(
          svgAssetPath: Assets.svgsUserMenuLogout,
          title: context.strings.title_logout,
          titleColor: context.appColors.bearish,
          onTap: () => _showLogoutConfirmDialog(context),
        ),
        Center(
          child: Column(
            children: [
              Dimens.vGap28,
              FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    var packageInfo = snapshot.data;
                    if (packageInfo == null) {
                      return const SizedBox();
                    }
                    return Text(
                      context.strings.format_version(packageInfo.version),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.textColorTheme.textColorHelper,
                      ),
                    );
                  }),
              Dimens.vGap40,
            ],
          ),
        ),
        Dimens.safeBottomSpace
      ],
    );
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────────

  void _showLogoutConfirmDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          context.strings.title_logout,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          context.strings.message_signout_sure,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.strings.cancel,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: Text(
              context.strings.action_confirm,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await injector<AuthSessionCoordinator>().logout();
    Get.offAllNamed(Routes.welcome);
  }

  void openWeb(String url) async {
    Get.to(() => WebViewScreen(url: url));
  }
}
