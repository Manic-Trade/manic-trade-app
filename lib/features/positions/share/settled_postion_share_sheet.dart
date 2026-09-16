import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/features/positions/model/history_position_vo.dart';
import 'package:finality/features/positions/share/settled_postion_share_card.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class SettledPositionShareSheet extends StatefulWidget {
  final bool isAgent;
  final HistoryPositionVO item;

  const SettledPositionShareSheet(
      {super.key, required this.item, required this.isAgent});

  @override
  State<SettledPositionShareSheet> createState() =>
      _SettledPositionShareSheetState();
}

class _SettledPositionShareSheetState extends State<SettledPositionShareSheet> {
  late final screenshotController = ScreenshotController();
  bool _isSharing = false;
  late final ConfettiController _controllerTopCenter;

  HistoryPositionVO get item => widget.item;

  @override
  void initState() {
    super.initState();
    _controllerTopCenter =
        ConfettiController(duration: const Duration(milliseconds: 650));
    if (widget.item.isSettledWin) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Future.delayed(const Duration(milliseconds: 350), () {
          _controllerTopCenter.play();
          HapticFeedbackUtils.heavyImpact();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DragHandle(),
          Expanded(
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 32, right: 32, top: 32, bottom: 40),
                            child: Screenshot(
                              controller: screenshotController,
                              child: ValueListenableBuilder(
                                valueListenable: item.tradingPair,
                                builder: (context, tradingPair, _) {
                                  final pipSize = tradingPair?.pipSize ?? 2;
                                  final pairName = tradingPair?.pairName ??
                                      '${item.baseAsset.toUpperCase()}/USD';
                                  final directionLabel =
                                      item.isHigh ? 'Long' : 'Short';
                                  final modeLabel =
                                      item.modeDisplay.toUpperCase();

                                  return SettledPositionShareCard(
                                    isHigh: item.isHigh,
                                    isWin: item.isSettledWin,
                                    pnlDisplay: item.pnlPercent.toString(),
                                    pnlSign: item.pnlSign,
                                    subtitle: 'PNL · $pairName',
                                    headerInfo:
                                        '${directionLabel.toUpperCase()} · $modeLabel',
                                    directionDisplay: directionLabel,
                                    durationDisplay: item.durationDisplayShort,
                                    profitDisplay: item.profitDisplay,
                                    entryPriceDisplay:
                                        item.getEntryPriceDisplay(pipSize),
                                    closePriceDisplay:
                                        item.getClosePriceDisplay(pipSize),
                                    investedDisplay: item.amountDisplay,
                                    isAgent: widget.isAgent,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Dimens.vGap8,
                      Touchable.button(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          height: 48,
                          child: FilledButton(
                              onPressed: () {
                                HapticFeedbackUtils.lightImpact();
                                share();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(RemixIcons.share_forward_line,
                                      size: 22,
                                      color: context.colorScheme.onPrimary),
                                  Dimens.hGap8,
                                  Text(
                                    "Share Trade",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      Dimens.vGap16,
                    ],
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
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
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _saveImage(Uint8List byteData) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String imageName = 'trade_share_$timestamp.jpg';
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

Future<void> showSettledPositionShareSheet(
  BuildContext context, {
  required HistoryPositionVO item,
  bool isAgent = false,
}) {
  // return showModalBottomSheet(
  //   backgroundColor: Colors.transparent,
  //   elevation: 0,
  //   isScrollControlled: true,
  //   context: context,
  //   builder: (_) => SettledPositionShareSheet(item: item, isAgent: isAgent),
  // );
  return showCupertinoModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    expand: true,
    duration: const Duration(milliseconds: 250),
    topRadius: Dimens.sheetTopRadius,
    builder: (_) => SettledPositionShareSheet(item: item, isAgent: isAgent),
  );
}
