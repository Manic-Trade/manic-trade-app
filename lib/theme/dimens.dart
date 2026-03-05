import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dimens {
  Dimens._internal();

  static const safeBottomSpace =
      SafeArea(top: false, right: false, left: false, child: emptyBox);
  static const safeTopSpace =
      SafeArea(bottom: false, right: false, left: false, child: emptyBox);

  static const emptyBox = SizedBox.shrink();
  static const divider = Divider();
  static const lineWidth = 0.7;
  static const screenHorizontalMargin = 16.0;
  static const sheetHorizontalMargin = 20.0;
  static const sheetTopRadius = Radius.circular(20);

  static const vGap2 = SizedBox(height: 2);
  static const vGap4 = SizedBox(height: 4);
  static const vGap6 = SizedBox(height: 6);
  static const vGap8 = SizedBox(height: 8);
  static const vGap10 = SizedBox(height: 10);
  static const vGap12 = SizedBox(height: 12);
  static const vGap14 = SizedBox(height: 14);
  static const vGap16 = SizedBox(height: 16);
  static const vGap20 = SizedBox(height: 20);
  static const vGap24 = SizedBox(height: 24);
  static const vGap28 = SizedBox(height: 28);
  static const vGap32 = SizedBox(height: 32);
  static const vGap40 = SizedBox(height: 40);

  static const hGapScreenMargin = SizedBox(width: screenHorizontalMargin);
  static const hGapSheetMargin = SizedBox(width: sheetHorizontalMargin);
  static const hGap2 = SizedBox(width: 2);
  static const hGap4 = SizedBox(width: 4);
  static const hGap6 = SizedBox(width: 6);
  static const hGap8 = SizedBox(width: 8);
  static const hGap10 = SizedBox(width: 10);
  static const hGap12 = SizedBox(width: 12);
  static const hGap16 = SizedBox(width: 16);
  static const hGap24 = SizedBox(width: 24);
  static const hGap32 = SizedBox(width: 32);
  static const hGap40 = SizedBox(width: 40);

  static const edgeInsetsScreenH =
      EdgeInsets.symmetric(horizontal: screenHorizontalMargin);
  static const edgeInsetsSheetH =
      EdgeInsets.symmetric(horizontal: sheetHorizontalMargin);
  static const edgeInsetsH2 = EdgeInsets.symmetric(horizontal: 2);
  static const edgeInsetsH4 = EdgeInsets.symmetric(horizontal: 4);
  static const edgeInsetsH8 = EdgeInsets.symmetric(horizontal: 8);
  static const edgeInsetsH12 = EdgeInsets.symmetric(horizontal: 12);
  static const edgeInsetsH14 = EdgeInsets.symmetric(horizontal: 14);
  static const edgeInsetsH16 = EdgeInsets.symmetric(horizontal: 16);
  static const edgeInsetsH18 = EdgeInsets.symmetric(horizontal: 18);
  static const edgeInsetsH20 = EdgeInsets.symmetric(horizontal: 20);
  static const edgeInsetsH24 = EdgeInsets.symmetric(horizontal: 24);
  static const edgeInsetsH28 = EdgeInsets.symmetric(horizontal: 24);
  static const edgeInsetsH32 = EdgeInsets.symmetric(horizontal: 32);
  static const edgeInsetsH36 = EdgeInsets.symmetric(horizontal: 36);
  static const edgeInsetsH40 = EdgeInsets.symmetric(horizontal: 40);

  static const edgeInsetsV4 = EdgeInsets.symmetric(vertical: 4);
  static const edgeInsetsV8 = EdgeInsets.symmetric(vertical: 8);
  static const edgeInsetsV12 = EdgeInsets.symmetric(vertical: 12);
  static const edgeInsetsV16 = EdgeInsets.symmetric(vertical: 16);
  static const edgeInsetsV20 = EdgeInsets.symmetric(vertical: 20);
  static const edgeInsetsV24 = EdgeInsets.symmetric(vertical: 24);

  static const edgeInsetsH16V8 =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const edgeInsetsH16V12 =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  static const edgeInsetsA4 = EdgeInsets.all(4);
  static const edgeInsetsA8 = EdgeInsets.all(8);
  static const edgeInsetsA12 = EdgeInsets.all(12);
  static const edgeInsetsA16 = EdgeInsets.all(16);
  static const edgeInsetsA24 = EdgeInsets.all(24);

  static const edgeInsetsR4 = EdgeInsets.only(right: 4);
  static const edgeInsetsR8 = EdgeInsets.only(right: 8);
  static const edgeInsetsR12 = EdgeInsets.only(right: 12);
  static const edgeInsetsR16 = EdgeInsets.only(right: 16);
  static const edgeInsetsR24 = EdgeInsets.only(right: 24);

  static const edgeInsetsL4 = EdgeInsets.only(left: 4);
  static const edgeInsetsL8 = EdgeInsets.only(left: 8);
  static const edgeInsetsL12 = EdgeInsets.only(left: 12);
  static const edgeInsetsL24 = EdgeInsets.only(left: 24);

  static const edgeInsetsT4 = EdgeInsets.only(top: 4);
  static const edgeInsetsT8 = EdgeInsets.only(top: 8);
  static const edgeInsetsT12 = EdgeInsets.only(top: 12);
  static const edgeInsetsT16 = EdgeInsets.only(top: 16);
  static const edgeInsetsT24 = EdgeInsets.only(top: 24);
  static const edgeInsetsT32 = EdgeInsets.only(top: 32);

  static const edgeInsetsB4 = EdgeInsets.only(bottom: 4);
  static const edgeInsetsB8 = EdgeInsets.only(bottom: 8);
  static const edgeInsetsB12 = EdgeInsets.only(bottom: 12);
  static const edgeInsetsB24 = EdgeInsets.only(bottom: 24);

  static BorderRadius radius4 = BorderRadius.circular(4);
  static BorderRadius radius6 = BorderRadius.circular(6);
  static BorderRadius radius8 = BorderRadius.circular(8);
  static BorderRadius radius10 = BorderRadius.circular(10);
  static BorderRadius radius12 = BorderRadius.circular(12);
  static BorderRadius radius16 = BorderRadius.circular(16);
  static BorderRadius radius24 = BorderRadius.circular(24);
  static BorderRadius radius32 = BorderRadius.circular(32);
  static BorderRadius radius48 = BorderRadius.circular(48);

  static const ShapeBorder shapeT28 = RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)));

  /// 顶部状态栏的高度
  static double get statusBarHeight => MediaQuery.of(Get.context!).padding.top;

  /// 底部导航条的高度
  static double get bottomBarHeight =>
      MediaQuery.of(Get.context!).padding.bottom;
}
