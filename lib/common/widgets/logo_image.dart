import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:finality/common/utils/token_image_utils.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class LogoImage extends StatelessWidget {
  final String symbol;
  final String? iconURL;
  final Color? strokeColor;
  final double strokeWidth;
  final double fontSize;
  final double width;
  final double height;
  final Color? backgroundColor;

  const LogoImage({
    super.key,
    required this.iconURL,
    required this.symbol,
    required this.width,
    required this.height,
    this.strokeColor,
    this.strokeWidth = 1,
    this.fontSize = 10,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (iconURL.isNullOrEmpty()) {
      return _buildPlaceholder(context);
    }

    final url = iconURL!;

    if (url.length < 10) {
      var assetPath = TokenImageUtils.getTokenIconAssetPathBySymbol(url);
      if (assetPath != null) {
        return _buildAssetImage(assetPath);
      }
    }
    // 本地 asset 路径
    if (url.startsWith('assets')) {
      return _buildAssetImage(url);
    }

    // 根据 URL 获取对应的本地 asset 路径
    final assetPath = TokenImageUtils.getTokenIconAssetPathByUrl(url);
    if (assetPath != null) {
      return _buildAssetImage(assetPath);
    }

    // 网络图片
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      imageBuilder: (_, imageProvider) =>
          _buildCircleImage(image: imageProvider),
      placeholder: (_, __) => _buildPlaceholder(context),
      errorWidget: (_, __, ___) => _buildPlaceholder(context),
    );
  }

  /// 构建本地 asset 图片（支持 SVG 和普通图片）
  Widget _buildAssetImage(String assetPath) {
    if (assetPath.endsWith('.svg')) {
      return _buildCircleContainer(
        child: ClipOval(
          child: SvgPicture.asset(
            assetPath,
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return _buildCircleImage(image: AssetImage(assetPath));
  }

  /// 构建带圆形边框的图片容器
  Widget _buildCircleImage({required ImageProvider image}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: _circleBorder,
        image: DecorationImage(image: image, fit: BoxFit.cover),
      ),
    );
  }

  /// 构建圆形容器（用于 SVG 等需要 child 的场景）
  Widget _buildCircleContainer({required Widget child}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: _circleBorder,
      ),
      child: child,
    );
  }

  /// 圆形边框样式
  Border get _circleBorder => Border.all(
        color: strokeColor ?? Colors.transparent,
        width: strokeWidth,
      );

  /// 构建占位符（显示 symbol 首字母）
  Widget _buildPlaceholder(BuildContext context) {
    final maxLength = width ~/ fontSize;
    final displayText =
        symbol.substring(0, min(symbol.length, maxLength)).toUpperCase();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: strokeWidth,
        ),
      ),
      child: Center(
        child: Text(
          displayText,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: context.textTheme.labelMedium?.copyWith(
            fontSize: fontSize,
            color: context.textColorTheme.textColorSecondary,
          ),
        ),
      ),
    );
  }
}
