import 'dart:io';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/primary_async_button.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/features/feedback/feed_back_vm.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:store_scope/store_scope.dart';

/// 显示反馈全屏底部弹窗
Future<void> showFeedBackSheet(BuildContext context) {
  return showCupertinoModalBottomSheet(
    context: context,
    expand: true,
    duration: const Duration(milliseconds: 250),
    topRadius: Dimens.sheetTopRadius,
    builder: (_) => const FeedBackSheet(),
  );
}

class FeedBackSheet extends StatefulWidget {
  const FeedBackSheet({super.key});

  @override
  State<FeedBackSheet> createState() => _FeedBackSheetState();
}

class _FeedBackSheetState extends State<FeedBackSheet> with ScopedStateMixin {
  late final FeedBackVM viewModel;
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  /// 最多可选择的图片数量
  static const int _maxImages = 5;

  /// 选中的图片列表
  final List<XFile> _selectedImages = [];

  /// 提交中状态
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    viewModel = context.store.bindWithScoped(feedBackVMProvider, this);
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    setState(() {});
  }

  bool get _canSubmit => _contentController.text.trim().isNotEmpty;

  bool get _isMaxImagesReached => _selectedImages.length >= _maxImages;

  Future<void> _pickImage() async {
    if (_isMaxImagesReached) {
      AppToastManager.showFailed(
        title: context.strings.feedback_max_images_reached,
      );
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      // 检查是否已存在相同路径的图片
      final isDuplicate = _selectedImages.any((img) => img.path == image.path);
      if (isDuplicate && mounted) {
        AppToastManager.showFailed(
          title: context.strings.feedback_image_already_added,
        );
        return;
      }
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  /// 打开图片查看器
  void _openImageViewer(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _LocalPhotoGalleryScreen(
            imageFiles: _selectedImages.map((e) => File(e.path)).toList(),
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      setState(() {
        _selectedImages.removeAt(index);
      });
    }
  }

  Future<void> _submitFeedback() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      _showSubmitError(context.strings.feedback_content_empty);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final success = await viewModel.submitFeedback(
        content: content,
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
      );
      if (success && mounted) {
        AppToastManager.showSuccess(
            title: "Feedback Submitted!",
            subtitle: "Feedback submitted. Thanks for your support!");
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
      rethrow;
    }
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
      child: Column(
        children: [
          const DragHandle(),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    SvgPicture.asset(
                      Assets.svgsIcLeadingFeedBack,
                      width: 20,
                      height: 20,
                    ),
                    Dimens.hGap8,
                    Text(
                      context.strings.feedback_title,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: context.textColorTheme.textColorSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    // 滚动内容区
                    Expanded(
                      child: SingleChildScrollView(
                        padding: Dimens.edgeInsetsH16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 文字输入框
                            _buildContentInput(context),
                            Dimens.vGap16,
                            // 图片网格（预览 + 添加按钮）
                            _buildImageGrid(context),
                          ],
                        ),
                      ),
                    ),
                    // 底部提交按钮
                    _buildSendButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentInput(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: Dimens.radius6,
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: _contentController,
        readOnly: _isSubmitting,
        maxLines: null,
        expands: true,
        maxLength: 1000,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.textColorTheme.textColorSecondary,
          decorationColor: context.colorScheme.primary,
        ),
        decoration: InputDecoration(
          hintText: context.strings.feedback_hint,
          hintStyle: context.textTheme.bodyMedium?.copyWith(
            color: context.textColorTheme.textColorQuaternary,
          ),
          border: InputBorder.none,
          contentPadding: Dimens.edgeInsetsA16.copyWith(
            left: 10,
            top: 10,
            right: 10,
            bottom: 10,
          ),
          counterText: '',
        ),
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final items = <Widget>[
      // 已选图片缩略图
      ..._selectedImages.asMap().entries.map((entry) {
        final index = entry.key;
        final image = entry.value;
        return _ImagePreviewItem(
          imageFile: File(image.path),
          onTap: () => _openImageViewer(index),
          onRemove: _isSubmitting ? null : () => _removeImage(index),
        );
      }),
      // 添加图片按钮（未达上限且未提交时显示）
      if (!_isMaxImagesReached && !_isSubmitting) _buildAddImageSlot(context),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items,
    );
  }

  Widget _buildAddImageSlot(BuildContext context) {
    return Touchable.plain(
      onTap: () {
        _pickImage();
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: Dimens.radius6,
          border: Border.all(
            color: context.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.add,
          size: 24,
          color: context.textColorTheme.textColorHelper,
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return Padding(
      padding: Dimens.edgeInsetsA16,
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: PrimaryAsyncButton(
          onError: (error) {
            if (context.mounted) {
              _showSubmitError(ErrorHandler.getMessage(context, error));
            }
            return true;
          },
          onPressed: _canSubmit ? _submitFeedback : null,
          child: Text(context.strings.feedback_send),
        ),
      ),
    );
  }

  void _showSubmitError(String message) {
    AppToastManager.showFailed(title: message);
  }
}

class _ImagePreviewItem extends StatelessWidget {
  final File imageFile;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _ImagePreviewItem({
    required this.imageFile,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: Dimens.radius6,
            child: Image.file(
              imageFile,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 本地图片查看器
class _LocalPhotoGalleryScreen extends StatelessWidget {
  final List<File> imageFiles;
  final int initialIndex;

  const _LocalPhotoGalleryScreen({
    required this.imageFiles,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: initialIndex);
    return Theme(
      data: ThemeData(brightness: Brightness.dark),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: DismissiblePage(
          minScale: 0.2,
          onDismissed: () {
            Navigator.of(context).pop();
          },
          child: PhotoViewGallery.builder(
            backgroundDecoration:
                const BoxDecoration(color: Colors.transparent),
            itemCount: imageFiles.length,
            pageController: pageController,
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(imageFiles[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 1,
                maxScale: PhotoViewComputedScale.contained * 3,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            loadingBuilder: (BuildContext context, ImageChunkEvent? progress) {
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
