import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/bottom_sheet_navigator.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/features/utilities/share/profit_loss_share_widget.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ProfitLossShareSheet extends StatefulWidget {
  final String imageUrl;
  final String symbol;
  final String profitLossPctText;
  final bool isWin;
  final DateTime? since;

  const ProfitLossShareSheet(
      {super.key,
      required this.imageUrl,
      required this.symbol,
      required this.profitLossPctText,
      required this.isWin,
      this.since});

  @override
  State<ProfitLossShareSheet> createState() => _ProfitLossShareSheetState();
}

class _ProfitLossShareSheetState extends State<ProfitLossShareSheet> {
  late final screenshotController = ScreenshotController();
  bool _isSharing = false;
  late final ConfettiController _controllerTopCenter;

  @override
  void initState() {
    super.initState();
    _controllerTopCenter =
        ConfettiController(duration: const Duration(seconds: 1));
    if (widget.isWin) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Future.delayed(const Duration(milliseconds: 400), () {
          _controllerTopCenter.play();
          HapticFeedbackUtils.heavyImpact();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: Screenshot(
                    controller: screenshotController,
                    child: Container(
                      color: context.colorScheme.surface,
                      padding: EdgeInsets.only(
                          left: 60, right: 60, top: 60, bottom: 44),
                      child: ProfitLossShareWidget(
                        imageUrl: widget.imageUrl,
                        symbol: widget.symbol,
                        since: widget.since,
                        profitLossPctText: widget.profitLossPctText,
                        isWin: widget.isWin,
                      ),
                    ),
                  ),
                ),
              ),
              Touchable.button(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  height: 48,
                  child: FilledButton(
                      onPressed: () {
                        HapticFeedbackUtils.lightImpact();
                        share();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            Assets.svgsIcActionShare,
                            width: 20,
                            color: context.colorScheme.onPrimary,
                          ),
                          Dimens.hGap12,
                          Text(
                            context.strings.action_share_gains,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              height: 1,
                            ),
                          ),
                        ],
                      )),
                ),
              ),
              Dimens.vGap32,
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 120),
              child: ConfettiWidget(
                confettiController: _controllerTopCenter,
                blastDirectionality: BlastDirectionality.explosive,
                maxBlastForce: 35,
                minBlastForce: 25,
                shouldLoop: false,
                blastDirection: -pi / 2,
                numberOfParticles: 128,
                gravity: 1,
                particleDrag: 0.038,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _saveImage(Uint8List byteData) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String imageName = 'pl_share_$timestamp.jpg';
    final tempDir = await getTemporaryDirectory();
    final assetPath = '${tempDir.path}/$imageName';
    File file = await File(assetPath).create();
    await file.writeAsBytes(byteData);
    return assetPath;
  }

  Future<void> share() async {
    if (_isSharing) return;
    try {
      _isSharing = true;
      final box = context.findRenderObject() as RenderBox?;
      final image = await screenshotController.capture(
          delay: Duration(milliseconds: 100));
      if (image == null) return;
      final imagePath = await _saveImage(image);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(imagePath)],
          sharePositionOrigin:
              box == null ? null : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e, stackTrace) {
      logger.e("share error", error: e, stackTrace: stackTrace);
    } finally {
      _isSharing = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controllerTopCenter.dispose();
  }
}

showProfitLossShareSheet(BuildContext context,
    {required String imageUrl,
    required String symbol,
    required String profitLossPctText,
    required bool isWin,
    DateTime? since}) {
  return showCupertinoModalBottomSheet(
    context: context,
    expand: true,
    settings: const RouteSettings(name: RouteNames.profitLossShare),
    duration: const Duration(milliseconds: 250),
    topRadius: Dimens.sheetTopRadius,
    builder: (_) => BottomSheetNavigator(
      useNavigator: false,
      builder: (_) {
        return ProfitLossShareSheet(
          imageUrl: imageUrl,
          symbol: symbol,
          profitLossPctText: profitLossPctText,
          isWin: isWin,
          since: since,
        );
      },
    ),
  );
}
