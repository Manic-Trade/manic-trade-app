import 'package:flutter/foundation.dart';

class Removable {
  VoidCallback? _remove;

  Removable._(this._remove);

  void remove() {
    _remove?.call();
    _remove = null;
  }

  void cancel() {
    _remove?.call();
    _remove = null;
  }

  bool get isRemoved => _remove == null;
}

extension ValueNotifierExtension<T> on ValueListenable<T> {
  Removable listen(
    void Function(T event) onData, {
    bool immediate = false,
  }) {
    void listener() {
      onData(value);
    }

    if (immediate) {
      onData(value);
    }
    addListener(listener);
    return Removable._(() {
      removeListener(listener);
    });
  }
}
