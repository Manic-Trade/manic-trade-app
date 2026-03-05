import 'dart:async';

import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/utils/image_processing_utils.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/utils/qr_scan_gradient_utils.dart';
import 'package:finality/common/widgets/bottom_sheet_navigator.dart';
import 'package:finality/common/widgets/copyable_widget.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/data/drift/entities/network.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/data/realtime/model/holding_request.dart';
import 'package:finality/data/realtime/realtime_holding_transport.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/wallet/entities/unified_account.dart';
import 'package:finality/features/assets/receive/receive_share_helper.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../../routes/app_pages.dart';
import '../transfer/widgets/token_balance_button.dart';

Future<void> showReceiveBottomSheet(BuildContext context,
    {Token? token}) async {
  var walletAccounts = injector<WalletService>().walletAccounts.value;
  if (walletAccounts == null) return;
  var localToken = token ?? Tokens.usdc;
  var account = walletAccounts.accounts.firstWhereOrNull(
      (account) => account.networkCode == localToken.networkCode);
  if (account == null) return;
  var network = Networks.getNetwork(localToken.networkCode);
  if (network == null) return;
  if (!context.mounted) return;

  return showCupertinoModalBottomSheet(
    context: context,
    expand: true,
    settings: const RouteSettings(name: RouteNames.receive),
    duration: const Duration(milliseconds: 250),
    topRadius: Dimens.sheetTopRadius,
    builder: (_) => BottomSheetNavigator(
      useNavigator: false,
      builder: (_) => _ReceiveBottomSheet(
        token: localToken,
        account: account,
        network: network,
      ),
    ),
  );
}

class _ReceiveBottomSheet extends StatefulWidget {
  final Token token;
  final UnifiedAccount account;
  final Network network;

  const _ReceiveBottomSheet(
      {required this.token, required this.account, required this.network});

  @override
  State<_ReceiveBottomSheet> createState() => _ReceiveBottomSheetState();
}

class _ReceiveBottomSheetState extends State<_ReceiveBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sweepAnimation;
  late final ValueNotifier<Token> tokenNotifier = ValueNotifier(widget.token);
  final Map<String, MemoryImage> _circularNetworkImageCache = {};
  late final RealtimeHoldingTransport realtimeHoldingTransport = injector();
  final copyController = CopyController();
  final qrCodeScreenshotController = ScreenshotController();
  final ReceiveShareHelper shareHelper = ReceiveShareHelper();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _sweepAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.action_receive),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              share(context);
            },
            icon: const Icon(Icons.ios_share, size: 22),
          ),
        ],
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            children: [
              Dimens.vGap8,
              ValueListenableBuilder(
                  valueListenable: tokenNotifier,
                  builder: (context, token, child) {
                    return TokenBalanceButton.withStream(
                      token: token,
                      balanceStream: realtimeHoldingTransport
                          .subscribeHolding(HoldingRequest(
                            contractAddress: token.contractAddress,
                            networkCode: token.networkCode,
                            holderAddress: widget.account.address,
                          ))
                          .map((holding) => holding.balance),
                    );
                  }),
              Dimens.vGap40,
              Touchable.plain(
                onTap: () {
                  _copyAddress(context);
                },
                child: _buildQrCodeView(context),
              ),
              Dimens.vGap32,
              SizedBox(
                width: 100,
                // child: Text(
                //   textAlign: TextAlign.center,
                //   context.strings.message_receive_all_solana_assets,
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: context.textColorTheme.textColorSecondary,
                //   ),
                // ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAddressSection(context),
                  ],
                ),
              ),
              SizedBox(
                height: 56,
              ),
              // 底部充值按钮
            ],
          ),
        ),
      ),
    );
  }

  void share(BuildContext context) async {
    try {
      await shareHelper.shareQrCode(
        context: context,
        screenshotController: qrCodeScreenshotController,
      );
    } catch (e) {
      logger.e(e);
    }
  }

  _buildQrCodeView(BuildContext context) {
    return Screenshot(
      controller: qrCodeScreenshotController,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: context.theme.dividerColor.withOpacity(0.1), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ValueListenableBuilder(
            valueListenable: tokenNotifier,
            builder: (context, token, child) {
              return FutureBuilder(
                  future: _loadCircularIcon(token),
                  builder: (context, snapshot) {
                    return AnimatedBuilder(
                        animation: _sweepAnimation,
                        builder: (context, child) {
                          return QrImageView(
                            data: widget.account.address,
                            size: 248,
                            embeddedImage: snapshot.data,
                            embeddedImageStyle: QrEmbeddedImageStyle(
                              safeArea: true,
                              size: Size(48, 48),
                              embeddedImageShape: EmbeddedImageShape.circle,
                            ),
                            gapless: false,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                            eyeStyle: QrEyeStyle(borderRadius: 2),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.circle,
                              color: Colors.black,
                              borderRadius: 2,
                            ),
                            gradient: QrScanGradientUtils.buildSweepGradient(
                                _sweepAnimation.value),
                          );
                        });
                  });
            }),
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder(
              valueListenable: tokenNotifier,
              builder: (context, token, child) {
                return Text(
                  '${token.symbol} ${context.strings.title_address} (${widget.network.name})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textColorTheme.textColorPrimary,
                  ),
                );
              }),
          Dimens.vGap8,
          // 地址容器
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.account.address,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.textColorTheme.textColorSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Dimens.hGap24,
              Touchable.button(
                shrinkScaleFactor: 0.8,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(80, 40),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    foregroundColor: context.textColorTheme.textColorPrimary,
                  ),
                  onPressed: () {
                    HapticFeedbackUtils.lightImpact();
                    _copyAddress(context);
                  },
                  child: CopyableWidget(
                      maintain: true,
                      controller: copyController,
                      clickable: false,
                      content: widget.account.address,
                      child: Text(context.strings.copy_wallet_address)),
                ),
              ),
            ],
          ),
          Dimens.vGap24,
          // 警告信息
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
                Dimens.hGap8,
                Expanded(
                  child: Text(
                    context.strings.message_only_receive_network_assets(
                        widget.network.name),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<MemoryImage?> _loadCircularIcon(Token token) async {
    // 先检查缓存
    var cachedImage = _circularNetworkImageCache[token.iconUrl];
    if (cachedImage != null) {
      return cachedImage;
    }

    // 根据是否有本地资源路径选择加载方式
    final assetPath = Tokens.getIconAssetPath(token);
    final MemoryImage? image = assetPath != null
        ? await ImageProcessingUtils.createCircularAssetImage(assetPath)
        : await ImageProcessingUtils.createCircularNetworkImage(token.iconUrl);

    // 如果加载成功，缓存图片
    if (image != null) {
      _circularNetworkImageCache[token.iconUrl] = image;
    }

    return image;
  }

  _copyAddress(BuildContext context) {
    copyController.copy();
    //Fluttertoast.showToast(msg: context.strings.message_address_copied);
  }
}
