import 'package:flutter/foundation.dart'
    show ChangeNotifier, ValueListenable, VoidCallback;

/// 通过监听一个 ValueListenable 创建新的可监听计算值
/// 新的值通过 compute 函数计算得出
/// 只在被监听时才会监听输入的 ValueListenable，计算是惰性的
///
/// 用法示例:
/// ```dart
/// // 创建一个基础的值监听器
/// final counter = ValueNotifier<int>(0);
///
/// // 创建一个计算值监听器，值为counter的两倍
/// final doubledCounter = ComputedNotifier<int, int>(
///   source: counter,
///   compute: (value) => value * 2,
/// );
///
/// // 添加监听器
/// doubledCounter.addListener(() {
///   print('计算值更新为: ${doubledCounter.value}');
/// });
///
/// // 当源值改变时，计算值会自动更新
/// counter.value = 5; // 输出: 计算值更新为: 10
///
/// // 也可以使用扩展方法更简洁地创建
/// final squaredCounter = counter.compute((value) => value * value);
/// ```
///
/// 特点:
/// - 惰性计算：只在实际需要时才进行计算
/// - 自动依赖管理：只在有监听器时才监听源值
/// - 智能缓存：避免重复计算相同的值
/// - 内存优化：在没有监听器时会停止监听源值

/// 抽象基类，处理通用的监听和缓存逻辑
abstract class BaseComputedNotifier<T> extends ChangeNotifier
    implements ValueListenable<T> {
  BaseComputedNotifier();

  bool _isListening = false;
  T? _lastComputedValue;
  bool _hasComputedValue = false;

  /// 子类实现：检查源值是否发生变化
  bool hasSourceChanged();

  /// 子类实现：计算新值
  T computeValue();

  /// 子类实现：开始监听所有源
  void startSourceListening();

  /// 子类实现：停止监听所有源
  void stopSourceListening();

  @override
  T get value {
    if (hasListeners) {
      if (!_hasComputedValue) {
        _updateComputedValue();
      }
      return _lastComputedValue as T;
    }

    if (!_hasComputedValue || hasSourceChanged()) {
      _updateComputedValue();
    }

    return _lastComputedValue as T;
  }

  void _updateComputedValue() {
    final oldValue = _lastComputedValue;
    final hasComputedValue = _hasComputedValue;

    _lastComputedValue = computeValue();
    _hasComputedValue = true;

    if (!hasComputedValue || oldValue != _lastComputedValue) {
      notifyListeners();
    }
  }

  void _startListening() {
    if (!_isListening) {
      if (!_hasComputedValue || hasSourceChanged()) {
        _updateComputedValue();
      }
      startSourceListening();
      _isListening = true;
    }
  }

  void _stopListening() {
    if (_isListening) {
      stopSourceListening();
      _isListening = false;
    }
  }

  @override
  void addListener(VoidCallback listener) {
    final wasEmpty = !hasListeners;
    super.addListener(listener);
    if (wasEmpty) {
      _startListening();
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    final hadListeners = hasListeners;
    super.removeListener(listener);
    if (hadListeners && !hasListeners) {
      _stopListening();
    }
  }

  /// 强制重新计算
  /// 如果当前有监听器，则立即重新计算
  void invalidate() {
    _hasComputedValue = false;
    if (hasListeners) {
      _updateComputedValue();
    }
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}

// 单源计算值
class ComputedNotifier<T, A> extends BaseComputedNotifier<T> {
  ComputedNotifier({
    required ValueListenable<A> source,
    required T Function(A value) compute,
  })  : _source = source,
        _compute = compute;

  final ValueListenable<A> _source;
  final T Function(A value) _compute;
  A? _lastSourceValue;

  @override
  bool hasSourceChanged() => _lastSourceValue != _source.value;

  @override
  T computeValue() {
    _lastSourceValue = _source.value;
    return _compute(_lastSourceValue as A);
  }

  @override
  void startSourceListening() => _source.addListener(_updateComputedValue);

  @override
  void stopSourceListening() => _source.removeListener(_updateComputedValue);
}

// 双源计算值
class ComputedNotifier2<T, A, B> extends BaseComputedNotifier<T> {
  ComputedNotifier2({
    required ValueListenable<A> source1,
    required ValueListenable<B> source2,
    required T Function(A value1, B value2) compute,
  })  : _source1 = source1,
        _source2 = source2,
        _compute = compute;

  final ValueListenable<A> _source1;
  final ValueListenable<B> _source2;
  final T Function(A value1, B value2) _compute;

  A? _lastSource1Value;
  B? _lastSource2Value;

  @override
  bool hasSourceChanged() =>
      _lastSource1Value != _source1.value ||
      _lastSource2Value != _source2.value;

  @override
  T computeValue() {
    _lastSource1Value = _source1.value;
    _lastSource2Value = _source2.value;
    return _compute(_lastSource1Value as A, _lastSource2Value as B);
  }

  @override
  void startSourceListening() {
    _source1.addListener(_updateComputedValue);
    _source2.addListener(_updateComputedValue);
  }

  @override
  void stopSourceListening() {
    _source1.removeListener(_updateComputedValue);
    _source2.removeListener(_updateComputedValue);
  }
}

// 三源计算值
class ComputedNotifier3<T, A, B, C> extends BaseComputedNotifier<T> {
  ComputedNotifier3({
    required ValueListenable<A> source1,
    required ValueListenable<B> source2,
    required ValueListenable<C> source3,
    required T Function(A value1, B value2, C value3) compute,
  })  : _source1 = source1,
        _source2 = source2,
        _source3 = source3,
        _compute = compute;

  final ValueListenable<A> _source1;
  final ValueListenable<B> _source2;
  final ValueListenable<C> _source3;
  final T Function(A value1, B value2, C value3) _compute;

  A? _lastSource1Value;
  B? _lastSource2Value;
  C? _lastSource3Value;

  @override
  bool hasSourceChanged() =>
      _lastSource1Value != _source1.value ||
      _lastSource2Value != _source2.value ||
      _lastSource3Value != _source3.value;

  @override
  T computeValue() {
    _lastSource1Value = _source1.value;
    _lastSource2Value = _source2.value;
    _lastSource3Value = _source3.value;
    return _compute(
      _lastSource1Value as A,
      _lastSource2Value as B,
      _lastSource3Value as C,
    );
  }

  @override
  void startSourceListening() {
    _source1.addListener(_updateComputedValue);
    _source2.addListener(_updateComputedValue);
    _source3.addListener(_updateComputedValue);
  }

  @override
  void stopSourceListening() {
    _source1.removeListener(_updateComputedValue);
    _source2.removeListener(_updateComputedValue);
    _source3.removeListener(_updateComputedValue);
  }
}

// 四源计算值
class ComputedNotifier4<T, A, B, C, D> extends BaseComputedNotifier<T> {
  ComputedNotifier4({
    required ValueListenable<A> source1,
    required ValueListenable<B> source2,
    required ValueListenable<C> source3,
    required ValueListenable<D> source4,
    required T Function(A value1, B value2, C value3, D value4) compute,
  })  : _source1 = source1,
        _source2 = source2,
        _source3 = source3,
        _source4 = source4,
        _compute = compute;

  final ValueListenable<A> _source1;
  final ValueListenable<B> _source2;
  final ValueListenable<C> _source3;
  final ValueListenable<D> _source4;
  final T Function(A value1, B value2, C value3, D value4) _compute;

  A? _lastSource1Value;
  B? _lastSource2Value;
  C? _lastSource3Value;
  D? _lastSource4Value;

  @override
  bool hasSourceChanged() =>
      _lastSource1Value != _source1.value ||
      _lastSource2Value != _source2.value ||
      _lastSource3Value != _source3.value ||
      _lastSource4Value != _source4.value;

  @override
  T computeValue() {
    _lastSource1Value = _source1.value;
    _lastSource2Value = _source2.value;
    _lastSource3Value = _source3.value;
    _lastSource4Value = _source4.value;
    return _compute(
      _lastSource1Value as A,
      _lastSource2Value as B,
      _lastSource3Value as C,
      _lastSource4Value as D,
    );
  }

  @override
  void startSourceListening() {
    _source1.addListener(_updateComputedValue);
    _source2.addListener(_updateComputedValue);
    _source3.addListener(_updateComputedValue);
    _source4.addListener(_updateComputedValue);
  }

  @override
  void stopSourceListening() {
    _source1.removeListener(_updateComputedValue);
    _source2.removeListener(_updateComputedValue);
    _source3.removeListener(_updateComputedValue);
    _source4.removeListener(_updateComputedValue);
  }
}

// 五源计算值
class ComputedNotifier5<T, A, B, C, D, E> extends BaseComputedNotifier<T> {
  ComputedNotifier5({
    required ValueListenable<A> source1,
    required ValueListenable<B> source2,
    required ValueListenable<C> source3,
    required ValueListenable<D> source4,
    required ValueListenable<E> source5,
    required T Function(A value1, B value2, C value3, D value4, E value5)
        compute,
  })  : _source1 = source1,
        _source2 = source2,
        _source3 = source3,
        _source4 = source4,
        _source5 = source5,
        _compute = compute;

  final ValueListenable<A> _source1;
  final ValueListenable<B> _source2;
  final ValueListenable<C> _source3;
  final ValueListenable<D> _source4;
  final ValueListenable<E> _source5;
  final T Function(A value1, B value2, C value3, D value4, E value5) _compute;

  A? _lastSource1Value;
  B? _lastSource2Value;
  C? _lastSource3Value;
  D? _lastSource4Value;
  E? _lastSource5Value;

  @override
  bool hasSourceChanged() =>
      _lastSource1Value != _source1.value ||
      _lastSource2Value != _source2.value ||
      _lastSource3Value != _source3.value ||
      _lastSource4Value != _source4.value ||
      _lastSource5Value != _source5.value;

  @override
  T computeValue() {
    _lastSource1Value = _source1.value;
    _lastSource2Value = _source2.value;
    _lastSource3Value = _source3.value;
    _lastSource4Value = _source4.value;
    _lastSource5Value = _source5.value;
    return _compute(
      _lastSource1Value as A,
      _lastSource2Value as B,
      _lastSource3Value as C,
      _lastSource4Value as D,
      _lastSource5Value as E,
    );
  }

  @override
  void startSourceListening() {
    _source1.addListener(_updateComputedValue);
    _source2.addListener(_updateComputedValue);
    _source3.addListener(_updateComputedValue);
    _source4.addListener(_updateComputedValue);
    _source5.addListener(_updateComputedValue);
  }

  @override
  void stopSourceListening() {
    _source1.removeListener(_updateComputedValue);
    _source2.removeListener(_updateComputedValue);
    _source3.removeListener(_updateComputedValue);
    _source4.removeListener(_updateComputedValue);
    _source5.removeListener(_updateComputedValue);
  }
}

// 六源计算值
class ComputedNotifier6<T, A, B, C, D, E, F> extends BaseComputedNotifier<T> {
  ComputedNotifier6({
    required ValueListenable<A> source1,
    required ValueListenable<B> source2,
    required ValueListenable<C> source3,
    required ValueListenable<D> source4,
    required ValueListenable<E> source5,
    required ValueListenable<F> source6,
    required T Function(
            A value1, B value2, C value3, D value4, E value5, F value6)
        compute,
  })  : _source1 = source1,
        _source2 = source2,
        _source3 = source3,
        _source4 = source4,
        _source5 = source5,
        _source6 = source6,
        _compute = compute;

  final ValueListenable<A> _source1;
  final ValueListenable<B> _source2;
  final ValueListenable<C> _source3;
  final ValueListenable<D> _source4;
  final ValueListenable<E> _source5;
  final ValueListenable<F> _source6;
  final T Function(A value1, B value2, C value3, D value4, E value5, F value6)
      _compute;

  A? _lastSource1Value;
  B? _lastSource2Value;
  C? _lastSource3Value;
  D? _lastSource4Value;
  E? _lastSource5Value;
  F? _lastSource6Value;

  @override
  bool hasSourceChanged() =>
      _lastSource1Value != _source1.value ||
      _lastSource2Value != _source2.value ||
      _lastSource3Value != _source3.value ||
      _lastSource4Value != _source4.value ||
      _lastSource5Value != _source5.value ||
      _lastSource6Value != _source6.value;

  @override
  T computeValue() {
    _lastSource1Value = _source1.value;
    _lastSource2Value = _source2.value;
    _lastSource3Value = _source3.value;
    _lastSource4Value = _source4.value;
    _lastSource5Value = _source5.value;
    _lastSource6Value = _source6.value;
    return _compute(
      _lastSource1Value as A,
      _lastSource2Value as B,
      _lastSource3Value as C,
      _lastSource4Value as D,
      _lastSource5Value as E,
      _lastSource6Value as F,
    );
  }

  @override
  void startSourceListening() {
    _source1.addListener(_updateComputedValue);
    _source2.addListener(_updateComputedValue);
    _source3.addListener(_updateComputedValue);
    _source4.addListener(_updateComputedValue);
    _source5.addListener(_updateComputedValue);
    _source6.addListener(_updateComputedValue);
  }

  @override
  void stopSourceListening() {
    _source1.removeListener(_updateComputedValue);
    _source2.removeListener(_updateComputedValue);
    _source3.removeListener(_updateComputedValue);
    _source4.removeListener(_updateComputedValue);
    _source5.removeListener(_updateComputedValue);
    _source6.removeListener(_updateComputedValue);
  }
}

extension ComputedNotifierExtension<T> on ValueListenable<T> {
  ComputedNotifier<R, T> computed<R>(R Function(T value) compute) =>
      ComputedNotifier(source: this, compute: compute);

  ComputedNotifier2<R, T, B> computed2<R, B>(
    ValueListenable<B> other,
    R Function(T value1, B value2) compute,
  ) =>
      ComputedNotifier2(
        source1: this,
        source2: other,
        compute: compute,
      );

  ComputedNotifier3<R, T, B, C> computed3<R, B, C>(
    ValueListenable<B> second,
    ValueListenable<C> third,
    R Function(T value1, B value2, C value3) compute,
  ) =>
      ComputedNotifier3(
        source1: this,
        source2: second,
        source3: third,
        compute: compute,
      );

  ComputedNotifier4<R, T, B, C, D> computed4<R, B, C, D>(
    ValueListenable<B> second,
    ValueListenable<C> third,
    ValueListenable<D> fourth,
    R Function(T value1, B value2, C value3, D value4) compute,
  ) =>
      ComputedNotifier4(
        source1: this,
        source2: second,
        source3: third,
        source4: fourth,
        compute: compute,
      );

  ComputedNotifier5<R, T, B, C, D, E> computed5<R, B, C, D, E>(
    ValueListenable<B> second,
    ValueListenable<C> third,
    ValueListenable<D> fourth,
    ValueListenable<E> fifth,
    R Function(T value1, B value2, C value3, D value4, E value5) compute,
  ) =>
      ComputedNotifier5(
        source1: this,
        source2: second,
        source3: third,
        source4: fourth,
        source5: fifth,
        compute: compute,
      );

  ComputedNotifier6<R, T, B, C, D, E, F> computed6<R, B, C, D, E, F>(
    ValueListenable<B> second,
    ValueListenable<C> third,
    ValueListenable<D> fourth,
    ValueListenable<E> fifth,
    ValueListenable<F> sixth,
    R Function(T value1, B value2, C value3, D value4, E value5, F value6)
        compute,
  ) =>
      ComputedNotifier6(
        source1: this,
        source2: second,
        source3: third,
        source4: fourth,
        source5: fifth,
        source6: sixth,
        compute: compute,
      );
}
