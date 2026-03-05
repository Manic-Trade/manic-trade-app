import 'package:finality/data/drift/options_database.dart';
import 'package:finality/domain/options/entities/options_trading_pair_identify.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionsTradingPairSelector {
  static const String _keySelectedAsset = "options_selected_asset";
  static const OptionsTradingPairIdentify defaultPairId =
      OptionsTradingPairIdentify(
    feedId: 'e62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43',
    baseAsset: 'btc',
  );

  final SharedPreferences _prefs;
  final OptionsDatabase _optionsDatabase;

  OptionsTradingPairSelector(this._prefs, this._optionsDatabase);

  late final BehaviorSubject<OptionsTradingPairIdentify?> _selectedPairSubject =
      BehaviorSubject.seeded(getSelectedPairId());

  /// 设置选中的交易对
  Future<void> setSelectedPairId(OptionsTradingPairIdentify identify) async {
    _setSelectedPairId(identify, shouldNotify: true);
  }

  Future<void> _setSelectedPairId(OptionsTradingPairIdentify identify,
      {bool shouldNotify = true}) async {
    final current = getSelectedPairId();
    if (current == identify) {
      return;
    }
    await _prefs.setString(_keySelectedAsset, identify.toSerialized());
    if (shouldNotify) {
      _selectedPairSubject.add(identify);
    }
  }

  /// 获取选中的交易对
  OptionsTradingPairIdentify? getSelectedPairId() {
    final serialized = _prefs.getString(_keySelectedAsset);
    if (serialized == null) {
      return null;
    }
    return OptionsTradingPairIdentify.fromSerialized(serialized);
  }

  /// 计算实际选中的交易对
  /// 如果当前选中的交易对不在数据库中，则自动选择一个新的
  /// 当数据库从空变为有数据时，也会自动选择
  Future<OptionsTradingPairIdentify?> _calculateRealSelectedPair(
    List<OptionsTradingPair> availablePairs,
    OptionsTradingPairIdentify? selectedIdentify,
  ) async {
    if (availablePairs.isEmpty) {
      // 数据库一条记录也没有，返回 null
      return null;
    }

    // 检查当前选中的交易对是否在数据库中
    if (selectedIdentify != null) {
      final exists =
          availablePairs.any((pair) => pair.feedId == selectedIdentify.feedId);
      if (exists) {
        // 当前选中的交易对存在，使用它
        await _setSelectedPairId(selectedIdentify, shouldNotify: false);
        return selectedIdentify;
      }
    }

    // 当前选中的交易对不存在（或为 null），自动选择一个新的
    // 这种情况包括：
    // 1. 之前选中的交易对被删除了
    // 2. 数据库从空变为有数据（selectedIdentify 为 null）
    final defaultPair = await _selectDefaultTradingPair(availablePairs);
    if (defaultPair != null) {
      await _setSelectedPairId(defaultPair, shouldNotify: false);
      // 更新 _selectedPairSubject，确保状态同步
      _selectedPairSubject.add(defaultPair);
      return defaultPair;
    }

    // 自动选择也没有，返回 null
    return null;
  }

  /// 从可用的交易对列表中选择一个默认的交易对
  /// 子类可以重写此方法来实现自定义的选择逻辑
  /// 如果返回 null，表示没有可选的交易对
  Future<OptionsTradingPairIdentify?> _selectDefaultTradingPair(
    List<OptionsTradingPair> availablePairs,
  ) async {
    if (availablePairs.isEmpty) {
      return null;
    }

    // 对列表进行排序：
    // 1. 先把 btc 排到最上面
    // 2. 再把 isPinned=true 的排到最上面
    final sortedPairs = List<OptionsTradingPair>.from(availablePairs);
    sortedPairs.sort((a, b) {
      // 第一优先级：isPinned 为 true 的排在前面
      if (a.isPinned != b.isPinned) {
        return b.isPinned ? 1 : -1;
      }
      // 第二优先级：在 isPinned 相同的组内，btc 排在前面
      final aIsDefault = a.feedId == defaultPairId.feedId;
      final bIsDefault = b.feedId == defaultPairId.feedId;
      if (aIsDefault != bIsDefault) {
        return bIsDefault ? 1 : -1;
      }
      return 0;
    });

    // 选择第一个（排序后的第一个）
    final firstPair = sortedPairs.first;
    return OptionsTradingPairIdentify(
      feedId: firstPair.feedId,
      baseAsset: firstPair.baseAsset,
    );
  }

  /// 通过数据库监听选中的交易对
  /// 当选中交易对变化时，会自动从数据库获取对应的 OptionsTradingPair
  /// 如果当前选中的交易对不存在于数据库中，会自动选择一个新的
  Stream<OptionsTradingPair?> streamSelectedTradingPair(
      {OptionsTradingPairIdentify? pairIdentify}) {
    if (pairIdentify != null) {
      return _streamTradingPairByIdentify(pairIdentify);
    }

    return _selectedPairSubject.stream.switchMap((selectedIdentify) {
      if (selectedIdentify == null) {
        // 如果没有选中的交易对，需要执行完整逻辑
        return _streamSelectedTradingPairWithFullLogic();
      }
      return _streamTradingPairByIdentify(selectedIdentify);
    });
  }

  /// 通过 identify 监听交易对
  /// 如果交易对存在则直接返回，否则降级到完整逻辑
  Stream<OptionsTradingPair?> _streamTradingPairByIdentify(
      OptionsTradingPairIdentify identify) {
    return _optionsDatabase.optionsTradingPairDao
        .streamItem(identify.feedId)
        .switchMap((pair) {
      if (pair != null) {
        // 如果存在，直接返回，避免加载所有数据
        return Stream.value(pair);
      }
      // 如果不存在，降级到完整逻辑（加载所有数据并计算）
      return _streamSelectedTradingPairWithFullLogic();
    });
  }

  /// 执行完整逻辑：加载所有数据并计算实际选中的交易对
  Stream<OptionsTradingPair?> _streamSelectedTradingPairWithFullLogic() {
    return Rx.combineLatest2(
      _optionsDatabase.optionsTradingPairDao.streamItems(),
      _selectedPairSubject.stream,
      (List<OptionsTradingPair> availablePairs,
          OptionsTradingPairIdentify? selectedIdentify) {
        return (availablePairs, selectedIdentify);
      },
    ).asyncMap((data) async {
      final (availablePairs, selectedIdentify) = data;
      final realSelected =
          await _calculateRealSelectedPair(availablePairs, selectedIdentify);
      return realSelected;
    }).switchMap((identify) {
      if (identify == null) {
        return Stream.value(null);
      }
      return _optionsDatabase.optionsTradingPairDao.streamItem(identify.feedId);
    });
  }

  /// 加载选中的交易对
  Future<OptionsTradingPair?> loadSelectedTradingPair() async {
    final selectedIdentify = getSelectedPairId();

    // 先检查 selectedIdentify 是否存在于数据库中
    if (selectedIdentify != null) {
      final pair = await _optionsDatabase.optionsTradingPairDao
          .loadItem(selectedIdentify.feedId);
      if (pair != null) {
        // 如果存在，直接返回，不需要加载所有数据
        return pair;
      }
    }

    // 如果不存在，再执行完整的逻辑（加载所有数据并计算实际选中的交易对）
    final availablePairs =
        await _optionsDatabase.optionsTradingPairDao.loadAllItems();
    final realSelected =
        await _calculateRealSelectedPair(availablePairs, selectedIdentify);
    if (realSelected == null) {
      return null;
    }
    return _optionsDatabase.optionsTradingPairDao.loadItem(realSelected.feedId);
  }
}
