import 'package:dio/dio.dart';
import 'package:finality/core/error/exceptions/feed_back_exception.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/di/injector.dart';
import 'package:http/http.dart' hide MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:store_scope/store_scope.dart';

final feedBackVMProvider = ViewModelProvider<FeedBackVM>(
  (ref) => FeedBackVM(injector<ManicTradeDataSource>()),
);

/// 反馈页面 ViewModel
class FeedBackVM extends ViewModel {
  final ManicTradeDataSource _dataSource;

  FeedBackVM(this._dataSource);

  /// 提交反馈
  /// [content] 反馈内容
  /// [images] 图片文件列表
  Future<bool> submitFeedback({
    required String content,
    List<XFile>? images,
  }) async {
    final contentText = content.trim();
    if (contentText.isEmpty) {
      return false;
    }

    // 转换图片为 MultipartFile
    List<MultipartFile>? multipartImages;
    if (images != null && images.isNotEmpty) {
      multipartImages = await Future.wait(images.map((xFile) async {
        final bytes = await xFile.readAsBytes();
        final fileName = xFile.name;
        final mimeType = _getMimeType(fileName);
        return MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: mimeType,
        );
      }));
    }

    // 调用接口
    final response = await _dataSource.submitFeedback(
      content: contentText,
      images: multipartImages,
    );

    if (response.success) {
      return true;
    } else {
      throw FeedBackException(message: response.message ?? 'Feedback submit failed');
    }
  }

  /// 获取 MIME 类型
  MediaType _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'png');
    }
  }
}
