import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/theme/styles.dart';

import '../../../theme/dimens.dart';

class PhotoGalleryScreen extends StatelessWidget {
  final List<String> imageUrls;
  final List<String>? thumbnailUrls;
  final String? currentImage;

  const PhotoGalleryScreen(
      {super.key,
      required this.imageUrls,
      this.thumbnailUrls,
      this.currentImage});

  @override
  Widget build(BuildContext context) {
    var initialPage = 0;
    if (currentImage != null) {
      initialPage = imageUrls.indexOf(currentImage!);
    }
    var pageController = PageController(initialPage: initialPage);
    return Theme(
      data: ThemeData(brightness: Brightness.dark),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          systemOverlayStyle: AppStyles.immersiveSystemUiOverlayStyle(context,
              isDark: true, systemNavigationBarContrastEnforced: false),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: DismissiblePage(
          minScale: 0.2,
          onDismissed: () {
            Navigator.of(context).pop();
          },
          child: GestureDetector(
            onLongPress: () {
              int page = pageController.page?.round() ?? 0;
              _readySaveImage(context, imageUrls[page]);
            },
            child: PhotoViewGallery.builder(
              backgroundDecoration:
                  const BoxDecoration(color: Colors.transparent),
              itemCount: imageUrls.length,
              pageController: pageController,
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(imageUrls[index]),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained * 1,
                  maxScale: PhotoViewComputedScale.contained * 3,
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              loadingBuilder:
                  (BuildContext context, ImageChunkEvent? progress) {
                final photoView =
                    context.findAncestorWidgetOfExactType<PhotoView>();
                var key = photoView?.key;
                if (key is ObjectKey) {
                  var value = key.value;
                  if (value is int) {
                    if (thumbnailUrls != null &&
                        thumbnailUrls!.length > value) {
                      var thumbnailUrl = thumbnailUrls![value];
                      return Stack(children: [
                        Center(
                            key: key,
                            child: CachedNetworkImage(
                              key: key,
                              errorWidget: (context, url, error) =>
                                  Dimens.emptyBox,
                              imageUrl: thumbnailUrl,
                              fit: BoxFit.fitWidth,
                              width: double.infinity,
                            )),
                        _buildLoadingWidget(context, progress)
                      ]);
                    }
                  }
                }
                return _buildLoadingWidget(context, progress);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context, ImageChunkEvent? progress) {
    return Center(
      child: CircularProgressIndicator(
          value: progress != null && progress.expectedTotalBytes != null
              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
              : null),
    );
  }

  _readySaveImage(BuildContext context, String imageUrl) async {
    final fileInfo = await DefaultCacheManager().getFileFromCache(imageUrl);
    var file = fileInfo?.file;
    if (file != null && context.mounted) {
      showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              content: ListTile(
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _saveImage(context, file);
                },
                title: Text(
                  context.strings.action_save_image,
                  style: context.textTheme.labelLarge,
                ),
              ),
            );
          });
    }
  }

  Future<void> _saveImage(BuildContext context, File file) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      // 如果权限被拒绝，则进行相应处理，比如弹出权限请求对话框
      return;
    }
    final result = await ImageGallerySaverPlus.saveFile(file.path);
    if (result['isSuccess']) {
      if (context.mounted) {
        Fluttertoast.showToast(msg: context.strings.message_saved_to_album);
      }
    } else {
      if (context.mounted) {
        Fluttertoast.showToast(msg: context.strings.message_save_failed);
      }
    }
  }
}
