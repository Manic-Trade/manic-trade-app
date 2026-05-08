import 'dart:io';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/primary_async_button.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/features/feedback/feed_back_vm.dart';
import 'package:finality/theme/dimens.dart';
import 'package:finality/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:store_scope/store_scope.dart';

class FeedBackScreen extends StatefulWidget {
  const FeedBackScreen({super.key});

  @override
  State<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> with ScopedStateMixin {
  late final FeedBackVM viewModel;
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  /// 最多可选择的图片数量
  static const int _maxImages = 5;

  /// 选中的图片列表
  final List<XFile> _selectedImages = [];

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
    // 触发 UI 更新以刷新提交按钮状态
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
      showSubmitError(context.strings.feedback_content_empty);
      return;
    }

    final success = await viewModel.submitFeedback(
      content: content,
      images: _selectedImages.isNotEmpty ? _selectedImages : null,
    );
    if (success && mounted) {
      AppToastManager.showSuccess(
        title: context.strings.feedback_submit_success,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.feedback_title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: Dimens.edgeInsetsScreenH,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Dimens.vGap16,
                    // 文字输入框
                    _buildContentInput(theme, colorScheme),
                    Dimens.vGap16,
                    // 图片预览
                    _buildImagePreview(),
                    // 添加图片按钮
                    _buildImageActions(colorScheme),
                  ],
                ),
              ),
            ),
            // 底部提示和提交按钮
            _buildBottomSection(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildContentInput(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: Dimens.radius12,
      ),
      child: TextField(
        controller: _contentController,
        maxLines: 6,
        minLines: 6,
        maxLength: 1000,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: context.strings.feedback_hint,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          contentPadding: Dimens.edgeInsetsA16,
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImages.isEmpty) {
      return Dimens.emptyBox;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _selectedImages.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;
          return _ImagePreviewItem(
            imageFile: File(image.path),
            onTap: () => _openImageViewer(index),
            onRemove: () => _removeImage(index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageActions(ColorScheme colorScheme) {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.image_outlined,
          label: context.strings.feedback_add_image,
          onTap: _pickImage,
        ),
      ],
    );
  }

  Widget _buildBottomSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: PrimaryAsyncButton(
              onError: (error) {
                if (context.mounted) {
                  showSubmitError(ErrorHandler.getMessage(context, error));
                }
                return true;
              },
              onPressed: _canSubmit ? _submitFeedback : null,
              child: Text(context.strings.feedback_send),
            ),
          ),
        ],
      ),
    );
  }

  void showSubmitError(String message) {
    AppToastManager.showFailed(
      title: 'Submit failed',
    );
  }
}

class _ImagePreviewItem extends StatelessWidget {
  final File imageFile;
  final VoidCallback onTap;
  final VoidCallback onRemove;

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
            borderRadius: Dimens.radius8,
            child: Image.file(
              imageFile,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: Dimens.radius8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
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
          systemOverlayStyle: AppStyles.immersiveSystemUiOverlayStyle(
            context,
            isDark: true,
            systemNavigationBarContrastEnforced: false,
          ),
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
