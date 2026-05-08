import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class UiState<T> {
  final Object? fallback;

  UiState._internal({this.fallback});

  bool get isLoading => this is Loading<T>;

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is Failure<T>;

  bool get isInitial => this is Initial<T>;

  T? get value {
    var statefulResult = this;
    if (statefulResult is Success<T>) {
      return statefulResult.value;
    }
    return null;
  }

  T? get valueOrFallback {
    var value = this.value;
    if (value == null) {
      var object = fallback;
      if (object is T) {
        return object;
      }
    }
    return value;
  }

  Widget buildWidget(
      {required Widget Function(Loading<T>) onLoading,
      required Widget Function(Success<T>) onSuccess,
      required Widget Function(Failure<T>) onFailure,
      Widget Function(Initial<T>)? onInitial}) {
    var statefulResult = this;
    if (statefulResult is Loading<T>) {
      return onLoading.call(statefulResult);
    } else if (statefulResult is Success<T>) {
      return onSuccess.call(statefulResult);
    } else if (statefulResult is Failure<T>) {
      return onFailure.call(statefulResult);
    } else if (statefulResult is Initial<T>) {
      return onInitial?.call(statefulResult) ?? SizedBox.shrink();
    } else {
      throw UnsupportedError(
          "StatefulResult class should not have subclasses other than Loading, Success, Failure");
    }
  }

  void handle(
      {Function(Loading<T>)? onLoading,
      Function(Success<T>)? onSuccess,
      Function(Failure<T>)? onFailure}) {
    var statefulResult = this;
    if (statefulResult is Loading<T>) {
      onLoading?.call(statefulResult);
    } else if (statefulResult is Success<T>) {
      onSuccess?.call(statefulResult);
    } else if (statefulResult is Failure<T>) {
      onFailure?.call(statefulResult);
    } else {
      throw UnsupportedError(
          "StatefulResult class should not have subclasses other than Loading, Success, Failure");
    }
  }

  static UiState<T> initial<T>() {
    return Initial();
  }

  static UiState<T> loading<T>({Function? canceler, Object? fallback}) {
    return Loading(canceler: canceler, fallback: fallback);
  }

  static UiState<T> success<T>(T value) {
    return Success(value);
  }

  static UiState<T> failure<T>(Object? throwable,
      {Function()? retry, Object? fallback}) {
    return Failure(throwable, retry: retry, fallback: fallback);
  }

  /// 转换为 Loading 状态，自动保留当前值作为 fallback
  UiState<T> toLoading({Function? canceler}) {
    return Loading(canceler: canceler, fallback: valueOrFallback);
  }

  /// 转换为 Failure 状态，自动保留当前值作为 fallback
  UiState<T> toFailure(Object? throwable, {Function()? retry}) {
    return Failure(throwable, retry: retry, fallback: valueOrFallback);
  }
}

class Initial<T> extends UiState<T> with EquatableMixin {
  Initial._() : super._internal();

  factory Initial() => Initial._();

  @override
  List<Object?> get props => [fallback];
}

class Loading<T> extends UiState<T> with EquatableMixin {
  final Function? canceler;

  Loading({this.canceler, super.fallback}) : super._internal();

  void cancel() {
    canceler?.call();
  }

  @override
  List<Object?> get props => [canceler, fallback];
}

class Success<T> extends UiState<T> {
  @override
  final T value;

  Success(this.value) : super._internal();

}

class Failure<T> extends UiState<T> with EquatableMixin {
  final Object? throwable;
  final Function()? retry;

  Failure(this.throwable, {super.fallback, this.retry}) : super._internal();

  @override
  List<Object?> get props => [throwable, retry, fallback];
}

extension UiStateNotifierExtension<T> on ValueNotifier<UiState<T>> {
  void updateIfEmpty(UiState<T> Function() newState) async {
    if (value.valueOrFallback == null) {
      value = newState();
    }
  }
}
