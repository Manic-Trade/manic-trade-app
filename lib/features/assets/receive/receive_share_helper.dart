import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ReceiveShareHelper {
  bool _isSharing = false;

  bool get isSharing => _isSharing;

  Future<void> shareQrCode({
    required BuildContext context,
    required ScreenshotController screenshotController
  }) async {
    if (_isSharing) return;
    try {
      _isSharing = true;
      final box = context.findRenderObject() as RenderBox?;
      final chartImage = await screenshotController.capture();
      if (!context.mounted) return;
      if (chartImage != null && context.mounted) {
        final imagePath = await _saveImage(chartImage);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(imagePath)],
            sharePositionOrigin:
                box == null ? null : box.localToGlobal(Offset.zero) & box.size,
          ),
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      _isSharing = false;
    }
  }

    Future<String> _saveImage(Uint8List byteData) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String imageName = '$timestamp.jpg';
    final tempDir = await getTemporaryDirectory();
    final assetPath = '${tempDir.path}/$imageName';
    File file = await File(assetPath).create();
    await file.writeAsBytes(byteData);
    return assetPath;
  }
}
