import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/features/analysis/models/analysis_filter.dart';
import 'package:finality/features/analysis/models/analysis_vo.dart';
import 'package:finality/features/analysis/share/analysis_share_card.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class AnalysisShareSheet extends StatefulWidget {
  final WinRateVO winRateVO;
  final TimeRange? timeRange;
  final ModeFilter? modeFilter;
  final String? asset;
  const AnalysisShareSheet(
      {super.key,
      required this.winRateVO,
      this.timeRange,
      this.modeFilter,
      this.asset});

  @override
  State<AnalysisShareSheet> createState() => _AnalysisShareSheetState();
}

class _AnalysisShareSheetState extends State<AnalysisShareSheet> {
  late final screenshotController = ScreenshotController();
  bool _isSharing = false;
  late final ConfettiController _controllerTopCenter;

  @override
  void initState() {
    super.initState();
    _controllerTopCenter =
        ConfettiController(duration: const Duration(milliseconds: 650));
    if (widget.winRateVO.winRate > 50) {
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
                            padding: EdgeInsets.only(
                                left: 36, right: 36, top: 32, bottom: 40),
                            child: Screenshot(
                              controller: screenshotController,
                              child: AnalysisShareCard(
                                winRatePercent: widget.winRateVO.winRate,
                                wins: widget.winRateVO.wins,
                                totalTrades: widget.winRateVO.totalTrades,
                                losses: widget.winRateVO.losses,
                                subtitle: _buildSubtitle(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Dimens.vGap8,
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
                                  Icon(RemixIcons.share_forward_line,
                                      size: 22,
                                      color: context.colorScheme.onPrimary),
                                  Dimens.hGap8,
                                  Text(
                                    "Share Win Rate",
                                    style: TextStyle(
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

  String _buildSubtitle() {
    final timeLabel = (widget.timeRange ?? TimeRange.sevenDays).shareLabel;
    final parts = ['Win Rate', timeLabel];
    final asset = widget.asset;
    if (asset != null && asset.isNotEmpty) {
      parts.add(asset.toUpperCase());
    }
    final mode = widget.modeFilter;
    if (mode != null && mode != ModeFilter.all) {
      parts.add(mode.label);
    }
    return parts.join(' · ');
  }

  Future<String> _saveImage(Uint8List byteData) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String imageName = 'win_rate_share_$timestamp.jpg';
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

Future<void> showAnalysisShareSheet(
  BuildContext context,
  WinRateVO winRateVO, {
  TimeRange? timeRange,
  ModeFilter? modeFilter,
  String? asset,
}) {
  // return showModalBottomSheet(
  //   backgroundColor: Colors.transparent,
  //   elevation: 0,
  //   isScrollControlled: true,
  //   context: context,
  //   builder: (_) => AnalysisShareSheet(
  //     winRateVO: winRateVO,
  //     timeRange: timeRange,
  //     modeFilter: modeFilter,
  //     asset: asset,
  //   ),
  // );
  return showCupertinoModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    expand: true,
    duration: const Duration(milliseconds: 250),
    topRadius: Dimens.sheetTopRadius,
    builder: (_) => AnalysisShareSheet(
      winRateVO: winRateVO,
      timeRange: timeRange,
      modeFilter: modeFilter,
      asset: asset,
    ),
  );
}
