import 'dart:io';

import 'package:dio/dio.dart';
import 'package:finality/core/error/exceptions/feed_back_exception.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finality/common/utils/localization_extensions.dart';

import 'cancel_error.dart';

class ErrorHandler {
  ErrorHandler._();

  static String getMessage(BuildContext context, dynamic error) {
    if (error is String) {
      return error;
    } else if (error is FormatException) {
      return context.strings.error_format;
    } else if (error is SocketException) {
      return context.strings.error_connect;
    } else if (error is DioException) {
      var dioErrorType = error.type;
      if (dioErrorType == DioExceptionType.cancel) {
        return context.strings.cancelled;
      } else if (dioErrorType == DioExceptionType.connectionTimeout ||
          dioErrorType == DioExceptionType.receiveTimeout ||
          dioErrorType == DioExceptionType.sendTimeout) {
        return context.strings.error_http_timeout;
      } else if (dioErrorType == DioExceptionType.badResponse) {
        var response = error.response;
        if (response != null) {
          var data = response.data;
          var statusCode = response.statusCode;
          if (statusCode == 401) {
            var header = response.requestOptions.headers["Authorization"];
            if (header != null && header is String) {
              // TODO: handle token expired
            }
            return context.strings.message_logout_has_expired_detail;
          }
          if (data is Map<String, dynamic>) {
            var message = data["message"];
            if (message != null && message is String) {
              return message;
            }
          }

          if (statusCode != null) {
            return context.strings.error_http_status_error(statusCode);
          }
        }
      }
      return getMessage(context, error.error);
    } else if (error is CancelError) {
      return context.strings.cancelled;
    } else if (error is MissingPluginException) {
      return error.message ?? context.strings.error_default;
    } else if (error is PlatformException) {
      return error.message ?? context.strings.error_default;
    } else if (TurnkeyManager.checkIsTurnkeySessionValidError(error)) {
      return context.strings.message_logout_has_expired_detail;
    } else if (error is FeedBackException) {
      return error.message;
    } else {
      return context.strings.error_default;
    }
  }
}
