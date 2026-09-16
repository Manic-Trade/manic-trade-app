import 'package:cached_network_image/cached_network_image.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/error_view.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/core/notifier/multi_value_listenable_builder.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/model/ua/ua_models.dart';
import 'package:finality/features/deposit/vm/deposit_vm.dart';
import 'package:finality/features/deposit/widgets/address_section.dart';
import 'package:finality/features/deposit/widgets/dropdown_selector.dart';
import 'package:finality/features/deposit/widgets/success_card.dart';
import 'package:finality/features/deposit/widgets/sweeping_card.dart';
import 'package:finality/theme/attrs/clash_display_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:store_scope/store_scope.dart';

/// 打开充值 Sheet
Future<void> showDepositSheet(BuildContext context) {
  // showModalBottomSheet(
  //   context: context,
  //   isScrollControlled: true,
  //   backgroundColor: Colors.transparent,
  //   builder: (_) => const DepositeSheet(),
  // );

  return showCupertinoModalBottomSheet<void>(
    context: context,
    expand: true,
    duration: const Duration(milliseconds: 250),
    topRadius: Dimens.sheetTopRadius,
    builder: (_) => const DepositeSheet(),
  );
}

// ── DepositeSheet ─────────────────────────────────────────

class DepositeSheet extends StatefulWidget {
  const DepositeSheet({super.key});

  @override
  State<DepositeSheet> createState() => _DepositeSheetState();
}

class _DepositeSheetState extends State<DepositeSheet>
    with ScopedSpaceStateMixin {
  late final DepositVM _vm;
  bool _sweepingCardDismissed = false;
  bool _successCardDismissed = false;

  @override
  void initState() {
    super.initState();
    _vm = space.bind(depositVMProvider);
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
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DragHandle(),
                Dimens.vGap16,
                _buildHeader(context),
                Dimens.vGap32,
                // 数据加载状态
                Expanded(
                  child: ValueListenableBuilder<UiState<bool>>(
                    valueListenable: _vm.dataState,
                    builder: (context, dataState, _) {
                      return dataState.buildWidget(
                        onLoading: (_) => _buildContent(true),
                        onFailure: (failure) => _buildError(failure.throwable),
                        onSuccess: (_) => _buildContent(false),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Sweep 状态覆盖层（独立于数据加载）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ValueListenableBuilder<UiState<UASweepData>>(
                valueListenable: _vm.sweepState,
                builder: (context, sweepState, child) {
                  return sweepState.buildWidget(
                    onLoading: (_) {
                      if (_sweepingCardDismissed) {
                        return const SizedBox.shrink();
                      }
                      return _buildStatusCard(isSweeping: true);
                    },
                    onSuccess: (s) {
                      if (_successCardDismissed) {
                        return const SizedBox.shrink();
                      }
                      return _buildStatusCard(
                          isSweeping: false, sweepData: s.value);
                    },
                    onFailure: (_) => const SizedBox.shrink(),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: Dimens.edgeInsetsH16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEPOSIT',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: context.textColorTheme.textColorPrimary,
                      ),
                ),
                Text(
                  'Transfer funds from an external wallet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textColorTheme.textColorTertiary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object? throwable) {
    return Stack(
      children: [
        Visibility.maintain(
            visible: false, child: _buildContent(true, isOnError: true)),
        Positioned.fill(
            child: ErrorView(
                onRetry: _vm.retry,
                message: ErrorHandler.getMessage(context, throwable,
                    fallback:
                        "Couldn't load deposit details. Please try again."))),
      ],
    );
  }

  Widget _buildContent(bool isLoading, {bool isOnError = false}) {
    return Padding(
      padding: Dimens.edgeInsetsH16,
      child: Skeletonizer(
        enabled: isLoading && !isOnError,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Dimens.vGap16,
            _buildDropdowns(isLoading),
            Dimens.vGap32,
            Expanded(child: Center(child: _buildQRCode(isLoading))),
            Dimens.vGap32,
            if (isLoading)
              AddressSection(address: '', isLoading: true)
            else
              ValueListenableBuilder<String>(
                valueListenable: _vm.depositAddressNotifier,
                builder: (_, address, __) => AddressSection(address: address),
              ),
            Dimens.vGap32,
          ],
        ),
      ),
    );
  }

  // ── 链 & Token 下拉选择 ──────────────────────────────────

  Widget _buildDropdowns(bool isLoading) {
    return ValueListenableBuilder3<List<UAChain>, int, int>(
      first: _vm.chains,
      second: _vm.selectedChainIndex,
      third: _vm.selectedTokenIndex,
      builder: (context, chains, chainIdx, tokenIdx, _) {
        final tokens = _vm.tokens.value;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supported token',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFDADADA),
                        ),
                  ),
                  Dimens.vGap8,
                  DropdownSelector(
                    isLoading: isLoading,
                    items: tokens
                        .map((t) => DropdownItem(
                              id: t.symbol,
                              name: t.symbol,
                              iconUrl: t.icon,
                            ))
                        .toList(),
                    selectedIndex: tokenIdx,
                    onSelected: _vm.selectToken,
                  ),
                ],
              ),
            ),
            Dimens.hGap16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton.unite(
                    child: Row(
                      children: [
                        Text(
                          'Supported chain',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFDADADA),
                                  ),
                        ),
                        const SizedBox(width: 4),
                        Tooltip(
                          message:
                              'Minimum deposit amount required for the selected chain.',
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: const Duration(seconds: 3),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF212121),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          textStyle: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w400,
                            color: context.textColorTheme.textColorTertiary,
                          ).toClashDisplay(),
                          child: Row(
                            children: [
                              Text(
                                'Min \$${_vm.minDeposit}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF969696),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.info_outline,
                                size: 11,
                                color: const Color(0xFF969696),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Dimens.vGap6,
                  DropdownSelector(
                    isLoading: isLoading,
                    items: chains
                        .map((c) => DropdownItem(
                              id: c.chain,
                              name: c.chain,
                              iconUrl: c.chainIcon,
                            ))
                        .toList(),
                    selectedIndex: chainIdx,
                    onSelected: _vm.selectChain,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── QR Code ──────────────────────────────────────────────

  Widget _buildQRCode(bool isLoading) {
    if (isLoading) {
      return Center(
        child: Bone.square(
          size: 222,
          uniRadius: 8,
        ),
      );
    }
    return ValueListenableBuilder2<String, String>(
      first: _vm.depositAddressNotifier,
      second: _vm.tokenIconNotifier,
      builder: (context, address, tokenIcon, _) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                QrImageView(
                  size: 200,
                  padding: EdgeInsets.zero,
                  data: address.isEmpty ? ' ' : address,
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
                if (tokenIcon.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(3),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: tokenIcon,
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      placeholder: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 底部状态卡片容器 ──────────────────────────────────────

  Widget _buildStatusCard({
    required bool isSweeping,
    UASweepData? sweepData,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(top: BorderSide(color: Color(0xFF262626))),
        boxShadow: [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 40,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: isSweeping
            ? SweepingCard(
                onClose: () => setState(() => _sweepingCardDismissed = true),
              )
            : SuccessCard(
                sweepResult: sweepData,
                onClose: () => setState(() => _successCardDismissed = true),
              ),
      ),
    );
  }
}
