import 'package:flutter/material.dart';

/// App 的文字主题配置类
///
/// 这个类定制了应用程序的所有文字样式，基于 [TextTheme] 进行定制。
/// 所有样式的默认值来自 [Typography] 类的 Material Design 3 实现。
///
/// 包括以下样式：
/// - Display styles (Large, Medium, Small): 用于大型展示文本
/// - Headline styles (Large, Medium, Small): 用于标题文本
/// - Title styles (Large, Medium, Small): 用于次级标题
/// - Body styles (Large, Medium, Small): 用于正文内容
/// - Label styles (Large, Medium, Small): 用于按钮和小型文本标签
/// 行高和字间距暂未定制 ,自动继承 TextTheme 的设置
class AppTextThemes {
  const AppTextThemes._();

  /// 应用自定义文字主题
  ///
  /// 基于传入的 [TextTheme] 和 [Color] 创建新的主题样式。
  /// 所有样式继承自 [Typography.material2021]。
  ///
  /// [textTheme] 基础文字主题，通常来自 [ThemeData.textTheme]
  /// [textColorPrimary] 主要文字颜色
  ///
  /// 返回定制化后的 [TextTheme]
  static TextTheme apply(TextTheme textTheme, Color textColorPrimary) {
    return textTheme.copyWith(
      /// 展示大型文本，用于特别强调的场景
      /// 例如：启动页面的标题、数据大屏的核心数据
      /// height: 1.12
      /// letterSpacing: -0.25
      displayLarge: textTheme.displayLarge?.copyWith(
        color: textColorPrimary,
        fontSize: 57,
      ),

      /// 中等展示文本，用于重要信息的展示
      /// 例如：欢迎页面的副标题
      /// height: 1.16
      /// letterSpacing: 0.0
      displayMedium: textTheme.displayMedium?.copyWith(
        color: textColorPrimary,
        fontSize: 45,
      ),

      /// 小型展示文本，用于次要展示内容
      /// 例如：统计数据的展示
      /// height: 1.22
      /// letterSpacing: 0.0
      displaySmall: textTheme.displaySmall?.copyWith(
        color: textColorPrimary,
        fontSize: 36,
      ),

      /// 大型标题，用于页面主标题
      /// 例如：页面顶部的标题
      /// height: 1.25
      /// letterSpacing: 0.0
      headlineLarge: textTheme.headlineLarge?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      ),

      /// 中等标题，用于重要内容区域的标题
      /// 例如：列表组的标题、弹窗的标题
      /// height: 1.29
      /// letterSpacing: 0.0
      headlineMedium: textTheme.headlineMedium?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 28,
      ),

      /// 小型标题，用于内容区块的标题
      /// 例如：卡片的标题、设置项的标题
      /// height: 1.33
      /// letterSpacing: 0.0
      headlineSmall: textTheme.headlineSmall?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),

      /// 大号标题文本，用于内容区域的主要标题
      /// 例如：列表项的主标题、表单区域的标题
      titleLarge: textTheme.titleLarge?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.25,
        letterSpacing: 0,
      ),

      /// 中等标题文本，用于次级内容的标题
      /// 例如：列表项的副标题、设置项的描述
      titleMedium: textTheme.titleMedium?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1,
        letterSpacing: 0,
      ),

      /// 小号标题文本，用于辅助性的标题文本
      /// 例如：表单字段的标签、小部件的标题
      titleSmall: textTheme.titleSmall?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1,
        letterSpacing: 0.32, // 2% of font size
      ),

      /// 大号正文文本，用于主要的文本内容
      /// 例如：文章正文、详细描述
      bodyLarge: textTheme.bodyLarge?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.25,
        letterSpacing: 0,
      ),

      /// 中等正文文本，用于一般的文本内容
      /// 例如：列表项描述、对话框内容
      bodyMedium: textTheme.bodyMedium?.copyWith(
          color: textColorPrimary,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.33,
          letterSpacing: 0.25),

      /// 小号正文文本，用于辅助性的文本内容
      /// 例如：提示文本、注释文本
      bodySmall: textTheme.bodySmall?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1,
        letterSpacing: 0,
      ),

      /// 大号标签文本，用于交互组件的文本
      /// 例如：大按钮的文本、Tab标签
      labelLarge: textTheme.labelLarge?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1,
        letterSpacing: 0,
      ),

      /// 中等标签文本，用于一般组件的文本
      /// 例如：普通按钮的文本、chip标签
      labelMedium: textTheme.labelMedium?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1,
        letterSpacing: 0,
      ),

      /// 小号标签文本，用于小型交互组件
      /// 例如：小按钮文本、角标文本
      labelSmall: textTheme.labelSmall?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        height: 1.25,
        letterSpacing: 0,
      ),
    );
  }
}
