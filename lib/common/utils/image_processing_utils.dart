import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:finality/core/logger.dart';

/// 图片处理工具类
class ImageProcessingUtils {
  /// 创建圆形网络图片
  /// [iconUrl] - 图片URL
  /// 返回处理后的圆形图片的MemoryImage，失败时返回null
  static Future<MemoryImage?> createCircularNetworkImage(String iconUrl) async {
    try {
      return await _loadImageFromProvider(CachedNetworkImageProvider(iconUrl));
    } catch (e) {
      // 图片加载失败时记录错误，但不阻塞UI
      logger.e("Failed to load circular network image", error: e);
      return null;
    }
  }

  /// 创建圆形Asset图片
  /// [assetPath] - Asset图片路径，例如 'assets/images/icon.png'
  /// 返回处理后的圆形图片的MemoryImage，失败时返回null
  static Future<MemoryImage?> createCircularAssetImage(String assetPath,
      {double? targetSize}) async {
    try {
      return await _loadImageFromProvider(AssetImage(assetPath),
          targetSize: targetSize);
    } catch (e) {
      // 图片加载失败时记录错误，但不阻塞UI
      logger.e("Failed to load circular asset image", error: e);
      return null;
    }
  }

  /// 通用的图片加载方法
  static Future<MemoryImage> _loadImageFromProvider(
    ImageProvider imageProvider, {
    double? targetSize,
  }) async {
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    final completer = Completer<ui.Image>();

    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        imageStream.removeListener(listener);
        completer.complete(info.image);
      },
      onError: (exception, stackTrace) {
        imageStream.removeListener(listener);
        completer.completeError(exception);
      },
    );

    imageStream.addListener(listener);
    final image = await completer.future;

    try {
      return await _createCircularImageFromUiImage(image,
          targetSize: targetSize);
    } finally {
      // 确保释放原始图片资源
      image.dispose();
    }
  }

  /// 将UI图片转换为圆形图片
  static Future<MemoryImage> _createCircularImageFromUiImage(
    ui.Image image, {
    double? targetSize,
  }) async {
    final size = targetSize ?? image.width.toDouble();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 绘制白色圆形背景
    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, backgroundPaint);

    // 应用圆形裁剪
    canvas.clipRRect(
      RRect.fromLTRBR(0, 0, size, size, Radius.circular(size / 2)),
    );

    // 绘制图片
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size, size),
      Paint(),
    );

    final picture = recorder.endRecording();
    try {
      final img = await picture.toImage(size.toInt(), size.toInt());
      try {
        final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          throw Exception('Failed to convert image to byte data');
        }
        return MemoryImage(byteData.buffer.asUint8List());
      } finally {
        img.dispose();
      }
    } finally {
      picture.dispose();
    }
  }
}
