import 'package:flutter/material.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
    String formatAgeShort(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return '${years}y';
    }  else if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inMinutes}m';
    }
  }

  String formatAge(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return '$years${context.strings.time_unit_year}';
    } else if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '$months${context.strings.time_unit_month}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}${context.strings.time_unit_day}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}${context.strings.time_unit_hour}';
    } else {
      return '${diff.inMinutes}${context.strings.time_unit_minute}';
    }
  }

  String formatFullDateTime() {
    final locale = Intl.getCurrentLocale();
    if (locale == 'zh') {
      return DateFormat('a h:mm - yyyy年MM月dd日', 'zh_CN').format(this);
    }
    return DateFormat('h:mm a - MMM dd, yyyy', locale).format(this);
  }

  String formatTimeWithAmPm() {
    final locale = Intl.getCurrentLocale();
    if (locale == 'zh') {
      return DateFormat('a h:mm', 'zh_CN').format(this);
    }
    return DateFormat('h:mm a', locale).format(this);
  }

    String formatHMMSSWithAmPm() {
    final locale = Intl.getCurrentLocale();
    if (locale == 'zh') {
      return DateFormat('a h:mm:ss', 'zh_CN').format(this);
    }
    return DateFormat('h:mm:ss a', locale).format(this);
  }


  String formatSinceDate() {
    final locale = Intl.getCurrentLocale();
    if (locale == 'zh') {
      return DateFormat('MM月dd日, yyyy', 'zh_CN').format(this);
    }
   return  DateFormat("MMM d, yyyy").format(this);
  }

    String formatSinceDateMonth() {
    final locale = Intl.getCurrentLocale();
    if (locale == 'zh') {
      return DateFormat('MM月dd日', 'zh_CN').format(this);
    }
   return  DateFormat("MMM d").format(this);
  }

      String formatSinceDateYear() {
    final locale = Intl.getCurrentLocale();
    if (locale == 'zh') {
      return DateFormat('yyyy年', 'zh_CN').format(this);
    }
   return  DateFormat("yyyy").format(this);
  }
}
