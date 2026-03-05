import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:finality/common/utils/localization_extensions.dart';

extension DateTimeExtensions on DateTime {
  String smartFormat(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(toLocal());
    if (diff.inSeconds < 60) {
      return context.strings.date_format_now;
    } else if (diff.inMinutes < 60) {
      return context.strings.date_format_minute_ago(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return context.strings.date_format_hour_ago(diff.inHours);
    } else if (diff.inDays < 7) {
      return context.strings.date_format_day_ago(diff.inDays);
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return context.strings.date_format_week_ago(weeks);
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return context.strings.date_format_month_ago(months);
    } else {
      final years = (diff.inDays / 365).floor();
      return context.strings.date_format_year_ago(years);
    }
  }

  String smartFormat2(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(toLocal());
    if (diff.inSeconds < 60) {
      return context.strings.date_format_now;
    } else if (diff.inMinutes < 60) {
      return context.strings.date_format_minute_ago2(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return context.strings.date_format_hour_ago2(diff.inHours);
    } else if (diff.inDays < 7) {
      return context.strings.date_format_day_ago2(diff.inDays);
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return context.strings.date_format_week_ago2(weeks);
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return context.strings.date_format_month_ago2(months);
    } else {
      final years = (diff.inDays / 365).floor();
      return context.strings.date_format_year_ago2(years);
    }
  }

  String formatDateTime() {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(this);
  }

  static final _MMMdyyyy = DateFormat("MMM d yyyy");

  String formatAsMMMdyyyy() => _MMMdyyyy.format(toLocal());

  static final _yyyyMMddHHmmss = DateFormat("yyyy/MM/dd HH:mm:ss");

  String formatAsYyyyMMddHHmmss() => _yyyyMMddHHmmss.format(toLocal());
}

extension StringDateTimeExtensions on String? {
  String smartFormat(BuildContext context) {
    return this == null || this!.isEmpty
        ? context.strings.date_format_now
        : DateTime.parse(this!).smartFormat(context);
  }
}
