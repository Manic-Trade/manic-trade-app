import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boring_avatars/flutter_boring_avatars.dart';
import 'package:get/get.dart';

import '../../features/utilities/viewer/photo_gallery_screen.dart';

class WalletAvatar extends StatelessWidget {
  final String? avatar;
  final double size;

  const WalletAvatar({super.key, required this.size, this.avatar});

  @override
  Widget build(BuildContext context) {
    var avatar = this.avatar;
    if (avatar != null) {
      if (avatar.isURL) {
        return GestureDetector(
          onTap: () => context.pushTransparentRoute(
            PhotoGalleryScreen(imageUrls: [avatar]),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              width: size,
              height: size,
              fit: BoxFit.cover,
              imageUrl: avatar,
              errorWidget: (_, __, ___) =>
                  Container(color: Colors.grey.shade200),
              placeholder: (_, __) => Container(color: Colors.grey.shade200),
            ),
          ),
        );
      }
      return _getBoringAvatar(avatar, size);
    }
    return _getBoringAvatar("default", size);
  }

  Widget _getBoringAvatar(String input, double size) {
    var colors = _generateColors(input);

    return SizedBox(
      width: size,
      height: size,
      child: BoringAvatar(
        type: BoringAvatarType.sunset,
        shape: const OvalBorder(),
        name: input,
        palette: BoringAvatarPalette(colors),
      ),
    );
  }

  List<Color> _generateColors(String input) {
    var colors = <Color>[];
    for (var i = 0; i < 5; i++) {
      colors.add(_generateColor(input, i));
    }
    return colors;
  }

  Color _generateColor(String input, int index) {
    final hash = md5.convert(utf8.encode(input + index.toString())).bytes;
    return Color.fromARGB(
      255,
      hash[0],
      hash[1],
      hash[2],
    );
  }
}
