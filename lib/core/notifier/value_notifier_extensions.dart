import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';

/// ValueNotifier that can use [notifyListeners] for Iterable.
/// 为集合类型提供的 ValueNotifier 实现
class CollectionNotifier<T> extends ValueNotifier<T> {
  CollectionNotifier(super.value);

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

/// ValueNotifier 的扩展方法，提供更简便的构建 Widget 方式
/// 用法示例:
/// ```dart
/// final counter = ValueNotifier(0);
/// counter.build((value) => Text('$value'));
/// // 或使用函数调用语法
/// counter((value) => Text('$value'));
/// ```
extension ValueListenableBuilderExtension<T> on ValueListenable<T> {
  /// Syntax sugar for [ValueListenableBuilder]
  Widget build(Widget Function(T val) builder) {
    return ValueListenableBuilder<T>(
      valueListenable: this,
      builder: (_, v, __) => builder(v),
    );
  }

  Widget call(Widget Function(T val) builder) => build(builder);
}

/// 为 null 值提供创建 ValueNotifier 的扩展方法
/// 用法示例:
/// ```dart
/// final nullableCounter = null.notif<int>();  // ValueNotifier<int?>
/// final nullableList = null.iNotif<List<int>>();  // CollectionNotifier<List<int>?>
/// ```
// ignore: prefer_void_to_null
extension NullValueNotifierExtension on Null {
  /// 创建可空类型的 ValueNotifier
  ValueNotifier<T?> notif<T>() {
    return ValueNotifier<T?>(null);
  }

  /// 创建可空类型的 CollectionNotifier
  CollectionNotifier<T?> iNotif<T>() {
    return CollectionNotifier<T?>(null);
  }
}

/// 为非空对象提供创建 ValueNotifier 的扩展方法
/// 用法示例:
/// ```dart
/// final counter = 0.notif;  // ValueNotifier<int>
/// final nullableCounter = 0.nNotif;  // ValueNotifier<int?>
/// ```
extension ValueNotifierExtension<T extends Object> on T {
  /// 创建非空类型的 ValueNotifier
  ValueNotifier<T> get notif => ValueNotifier<T>(this);

  /// 创建可空类型的 ValueNotifier
  ValueNotifier<T?> get nNotif => ValueNotifier<T?>(this);
}

/// 为集合类型提供创建 CollectionNotifier 的扩展方法
/// 用法示例:
/// ```dart
/// final list = <int>[].notif;  // CollectionNotifier<List<int>>
/// final nullableList = <int>[].nNotif;  // CollectionNotifier<List<int>?>
/// ```
extension IterableNotifierExtension<T extends Iterable> on T {
  /// 创建非空集合类型的 CollectionNotifier
  CollectionNotifier<T> get notif => CollectionNotifier<T>(this);

  /// 创建可空集合类型的 CollectionNotifier
  CollectionNotifier<T?> get nNotif => CollectionNotifier<T?>(this);
}

/// 为 Map 类型提供创建 CollectionNotifier 的扩展方法
/// 用法示例:
/// ```dart
/// final map = <String, int>{}.notif;  // CollectionNotifier<Map<String, int>>
/// final nullableMap = <String, int>{}.nNotif;  // CollectionNotifier<Map<String, int>?>
/// ```
extension MapValueNotifierExtension<T, E> on Map<T, E> {
  /// 创建非空 Map 类型的 CollectionNotifier
  CollectionNotifier<Map<T, E>> get notif =>
      CollectionNotifier<Map<T, E>>(this);

  /// 创建可空 Map 类型的 CollectionNotifier
  CollectionNotifier<Map<T, E>?> get nNotif =>
      CollectionNotifier<Map<T, E>?>(this);
}

/// 为 ValueNotifier 列表提供组合监听的扩展方法
/// 用法示例:
/// ```dart
/// final counter1 = 0.notif;
/// final counter2 = 0.notif;
/// [counter1, counter2].build((values) {
///   return Text('Counter1: ${values[0]}, Counter2: ${values[1]}');
/// });
/// ```
extension IterableValueListenableBuilderExtension<T> on List<ValueListenable<T>> {
  /// 同时监听多个 ValueNotifier 的变化并构建 Widget
  Widget build(Widget Function(List<T> vals) builder) => _build(builder, 0);

  Widget _build(Widget Function(List<T> vals) builder, int index) {
    if (index >= length) return builder(map((item) => item.value).toList());
    return elementAt(index).build((val) => _build(builder, index + 1));
  }

  Widget call(Widget Function(List<T> vals) builder) => build(builder);
}
