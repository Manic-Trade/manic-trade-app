/// UI数据包装类
/// [R] 是原始数据类型
/// [U] 是UI模型数据类型
class UiData<R, U> {
  /// 原始数据
  final R raw;

  /// UI模型数据
  final U uiModel;

  const UiData({
    required this.raw,
    required this.uiModel,
  });

  UiData<R, U> copyWith({
    R? raw,
    U? uiModel,
  }) {
    return UiData(
      raw: raw ?? this.raw,
      uiModel: uiModel ?? this.uiModel,
    );
  }

  /// 使用转换函数创建UI数据
  static UiData<R, U> from<R, U>({
    required R raw,
    required U Function(R raw) transform,
  }) {
    return UiData(
      raw: raw,
      uiModel: transform(raw),
    );
  }

  /// 转换UI模型数据，保持原始数据不变
  UiData<R, NewU> transformUiModel<NewU>(
    NewU Function(U uiModel) transform,
  ) {
    return UiData(
      raw: raw,
      uiModel: transform(uiModel),
    );
  }

  /// 便捷的转换方法
  T map<T>({
    required T Function(R raw, U uiModel) transform,
  }) {
    return transform(raw, uiModel);
  }
}

extension UiDataListExt<R, U> on List<UiData<R, U>> {
  /// 获取所有原始数据
  List<R> get raws => map((e) => e.raw).toList();

  /// 获取所有UI模型数据
  List<U> get uiModels => map((e) => e.uiModel).toList();
}
