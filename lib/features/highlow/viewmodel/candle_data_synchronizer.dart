import 'dart:async';
import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:dio/dio.dart';
import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/manic_price_data_source.dart';
import 'package:finality/data/socket/manic_socket_client.dart';
import 'package:finality/data/socket/shared_price_stream_manager.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/features/highlow/model/deriv_candle_mapper.dart';
import 'package:finality/features/highlow/utils/timebar_converter.dart';

/// K线数据同步器
/// 职责：协调接口数据和 socket 数据，保证数据完整性
///
/// 使用方式：
/// 1. 创建时配置好 asset 和 timeBar
/// 2. 调用 start() 传入回调，开始同步
/// 3. 切换 asset/timeBar 时，dispose 旧的，创建新的
class CandleDataSynchronizer {
  final String asset;
  final TimeBar timeBar;
  final ManicPriceDataSource _httpDataSource;
  final SharedPriceStreamManager _priceStreamManager;

  CandleDataSynchronizer({
    required this.asset,
    required this.timeBar,
    required ManicPriceDataSource httpDataSource,
    required SharedPriceStreamManager priceStreamManager,
  })  : _httpDataSource = httpDataSource,
        _priceStreamManager = priceStreamManager;

  // ========== 回调 ==========

  void Function(List<Candle> candles)? _onCandlesChanged;
  void Function(double price, int timestamp)? _onPriceChanged;
  void Function(UiState<bool> state)? _onInitialLoadStateChanged;
  void Function(UiState<void> state)? _onHistoryLoadStateChanged;
  void Function(bool isLive)? _onIsLiveChanged;
  void Function(bool noMoreHistory)? _onNoMoreHistoryChanged;

  // ========== 内部状态 ==========

  /// 当前 K 线数据（内部维护，用于增量更新）
  List<Candle> _candles = [];

  /// 当前初始加载状态
  UiState<bool> _initialLoadState = UiState.initial();

  PriceSubscription? _sharedPriceSubscription;
  StreamSubscription? _priceSubscription;
  StreamSubscription? _reconnectSubscription;
  CancelToken? _initialCandlesCT;
  CancelToken? _historyCandlesCT;

  /// 缓存的实时价格数据（当初始化数据还未加载完成时）
  final Map<int, ManicPriceData> _pendingPriceCache = {};

  /// Socket 连接成功的时间戳（毫秒）
  int? _socketConnectedTime;

  /// 接口数据返回的时间戳（毫秒）
  int? _apiDataReceivedTime;

  /// 是否已启动
  bool _isStarted = false;

  /// 是否已暂停
  bool _isPaused = false;

  /// 是否已销毁
  bool _isDisposed = false;

  /// 是否已经没有更多历史数据了
  bool _noMoreHistory = false;

  /// 最大允许的时间间隔（毫秒）
  static const int _maxAllowedGapMs = 5000;

  // ========== 对外属性 ==========

  /// 是否已启动
  bool get isStarted => _isStarted;

  /// 是否实时数据
  bool get isLive => _sharedPriceSubscription?.isConnected.value ?? false;
  Removable? _isLiveRemovable;

  /// 是否已暂停
  bool get isPaused => _isPaused;

  /// 是否已经没有更多历史数据
  bool get noMoreHistory => _noMoreHistory;

  /// 时间粒度（毫秒）
  int get granularityMs => TimeBarConverter.toSecondsOrThrow(timeBar) * 1000;

  // ========== 对外方法 ==========

  /// 开始同步数据
  /// 如果已经启动，会先停止再重新开始
  /// [onCandlesChanged] K线数据变化回调
  /// [onPriceChanged] 当前价格变化回调 (price, timestamp)
  /// [onInitialLoadStateChanged] 初始加载状态变化回调
  /// [onHistoryLoadStateChanged] 历史加载状态变化回调
  /// [onNoMoreHistoryChanged] "没有更多历史数据"状态变化回调
  Future<void> start({
    void Function(List<Candle> candles)? onCandlesChanged,
    void Function(double price, int timestamp)? onPriceChanged,
    void Function(UiState<bool> state)? onInitialLoadStateChanged,
    void Function(UiState<void> state)? onHistoryLoadStateChanged,
    void Function(bool isLive)? onIsLiveChanged,
    void Function(bool noMoreHistory)? onNoMoreHistoryChanged,
  }) async {
    if (_isDisposed) return;

    // 如果已经启动，先停止
    if (_isStarted) {
      await stop();
    }

    _isStarted = true;
    _isPaused = false;

    _onCandlesChanged = onCandlesChanged;
    _onPriceChanged = onPriceChanged;
    _onInitialLoadStateChanged = onInitialLoadStateChanged;
    _onHistoryLoadStateChanged = onHistoryLoadStateChanged;
    _onIsLiveChanged = onIsLiveChanged;
    _onNoMoreHistoryChanged = onNoMoreHistoryChanged;
    logger.d('CandleDataSynchronizer: 开始同步 asset=$asset, timeBar=$timeBar');

    // 开始加载数据（内部会创建 PriceSubscription 并设置监听）
    await _loadDataWithSocketSync();
  }

  /// 停止同步（取消所有请求和订阅，清空状态）
  Future<void> stop() async {
    if (!_isStarted || _isDisposed) return;

    logger.d('CandleDataSynchronizer: 停止同步');

    _isStarted = false;

    // 取消网络请求
    _initialCandlesCT?.cancel();
    _initialCandlesCT = null;
    _historyCandlesCT?.cancel();
    _historyCandlesCT = null;

    // 取消订阅
    await _priceSubscription?.cancel();
    _priceSubscription = null;
    await _reconnectSubscription?.cancel();
    _reconnectSubscription = null;
    _isLiveRemovable?.remove();
    _isLiveRemovable = null;

    // 释放共享价格订阅（引用计数 -1）
    _sharedPriceSubscription?.dispose();
    _sharedPriceSubscription = null;

    // 清空状态
    _candles = [];
    _pendingPriceCache.clear();
    _socketConnectedTime = null;
    _apiDataReceivedTime = null;
    _initialLoadState = UiState.initial();
    _noMoreHistory = false;
  }

  /// 加载更多历史数据
  Future<void> loadHistory() async {
    if (_isDisposed || !_isStarted) return;
    if (_candles.isEmpty) return;
    if (_initialLoadState.isLoading || _initialLoadState.isFailure) return;
    // 已经没有更多历史数据，直接返回
    if (_noMoreHistory) return;

    final timeframeSeconds = TimeBarConverter.toSecondsOrThrow(timeBar);

    _historyCandlesCT?.cancel();
    _historyCandlesCT = CancelToken();
    _onHistoryLoadStateChanged?.call(UiState.loading());

    try {
      final endTimeMs = _candles.first.epoch;
      var endTimeSeconds = (endTimeMs / 1000).toInt();
      final response = await _httpDataSource.getHistoricPrice(
        cancelToken: _historyCandlesCT,
        asset,
        timeframeSeconds * 1000,
        timeframeSeconds,
        endTime: endTimeSeconds - 1, //不减 1 秒服务端会把最后一条数据返回
      );

      if (response.candles.isEmpty ||
          (response.candles.length == 1 &&
              response.candles.first.timestamp >= endTimeSeconds)) {
        logger.d('CandleDataSynchronizer: 没有更多数据，所有历史数据已加载完成');
        _noMoreHistory = true;
        _onNoMoreHistoryChanged?.call(true);
        _onHistoryLoadStateChanged?.call(UiState.success(null));
        return;
      }
      // 按时间升序排序
      final sortedCandles = response.candles.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final historyCandles =
          sortedCandles.map((item) => item.toDerivCandle()).toList();

      _candles = [...historyCandles, ..._candles];
      _onCandlesChanged?.call(_candles);
      _onHistoryLoadStateChanged?.call(UiState.success(null));
    } catch (error, stackTrace) {
      logger.e(error, stackTrace: stackTrace);
      if (error is DioException && error.type == DioExceptionType.cancel) {
        return;
      }
      _onHistoryLoadStateChanged
          ?.call(UiState.failure(error, retry: loadHistory));
    }
  }

  /// 暂停同步（保留状态，只断开连接）
  Future<void> pause() async {
    if (_isPaused || _isDisposed || !_isStarted) return;
    _isPaused = true;

    logger.d('CandleDataSynchronizer: 暂停同步');

    // 取消订阅
    await _priceSubscription?.cancel();
    _priceSubscription = null;
    await _reconnectSubscription?.cancel();
    _reconnectSubscription = null;
    _isLiveRemovable?.remove();
    _isLiveRemovable = null;

    // 释放共享价格订阅（引用计数 -1）
    _sharedPriceSubscription?.dispose();
    _sharedPriceSubscription = null;
  }

  /// 恢复同步
  Future<void> resume() async {
    if (!_isPaused || _isDisposed || !_isStarted) return;
    _isPaused = false;

    logger.d('CandleDataSynchronizer: 恢复同步');

    await _loadDataWithSocketSync();
  }

  /// 销毁
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    logger.d('CandleDataSynchronizer: 销毁');

    // 复用 stop 逻辑
    _isStarted = true; // 临时设为 true 以便 stop 能执行
    await stop();
  }

  // ========== 内部方法 ==========

  /// 加载数据并同步 socket
  /// [sequential] 为 true 时，先订阅 socket 再请求接口，保证数据不断层
  Future<void> _loadDataWithSocketSync(
      {bool sequential = false, bool isRefresh = false}) async {
    if (_isDisposed || !_isStarted) return;

    // 重置时间戳
    _pendingPriceCache.clear();
    _socketConnectedTime = null;
    _apiDataReceivedTime = null;

    if (sequential) {
      // 顺序执行：先等待 socket 连接就绪，再请求接口，保证百分百不断层
      await _subscribeSocket();
      await _loadInitialData(isRefresh: isRefresh);
    } else {
      // 并行执行：socket 连接和接口请求同时进行
      await Future.wait([
        _subscribeSocket(),
        _loadInitialData(isRefresh: isRefresh),
      ]);
      // 检查是否存在数据断层风险
      _checkAndHandleDataGap();
    }
  }

  /// 通过 SharedPriceStreamManager 订阅 socket 数据
  Future<void> _subscribeSocket() async {
    if (_isDisposed || !_isStarted) return;

    // 清理旧的监听
    _priceSubscription?.cancel();
    _reconnectSubscription?.cancel();
    _isLiveRemovable?.remove();
    _sharedPriceSubscription?.dispose();

    // 创建新的共享价格订阅
    _sharedPriceSubscription =
        _priceStreamManager.subscribe(asset, timeBar: timeBar);
    _socketConnectedTime = await _sharedPriceSubscription!.connectReady;
    // 监听价格数据
    _priceSubscription =
        _sharedPriceSubscription!.priceStream.listen(_onPriceData);

    // 监听连接状态
    _isLiveRemovable = _sharedPriceSubscription!.isConnected.listen((isLive) {
      _onIsLiveChanged?.call(isLive);
    },immediate: true);

    // 监听重连事件
    _reconnectSubscription =
        _sharedPriceSubscription!.reconnectStream.listen((_) {
      if (_isPaused || _isDisposed || !_isStarted) return;
      logger.d('CandleDataSynchronizer: 检测到 socket 重连，重新加载数据');
      _loadDataWithSocketSync();
    });
  }

  /// 加载初始K线数据
  Future<void> _loadInitialData({bool isRefresh = false}) async {
    if (_isDisposed || !_isStarted) return;

    final timeframeSeconds = TimeBarConverter.toSecondsOrThrow(timeBar);

    if (_historyCandlesCT != null) {
      _historyCandlesCT!.cancel();
      _onHistoryLoadStateChanged?.call(UiState.success(null));
    }
    _initialCandlesCT?.cancel();
    _initialCandlesCT = CancelToken();
    _initialLoadState = UiState.loading(fallback: isRefresh);
    _onInitialLoadStateChanged?.call(_initialLoadState);

    try {
      final response = await _httpDataSource.getHistoricPrice(
        cancelToken: _initialCandlesCT,
        asset,
        timeframeSeconds * 1000,
        timeframeSeconds,
      );

      // 记录接口数据返回时间
      _apiDataReceivedTime = DateTime.now().millisecondsSinceEpoch;

      // 按时间升序排序
      final sortedCandles = response.candles.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      var candleList =
          sortedCandles.map((item) => item.toDerivCandle()).toList();

      // 合并缓存的实时数据
      candleList = _mergePendingPriceData(candleList);
      _pendingPriceCache.clear();

      _candles = candleList;
      _initialLoadState = UiState.success(isRefresh);
      if (candleList.isEmpty) {
        _noMoreHistory = true;
        _onNoMoreHistoryChanged?.call(true);
      } else {
        // 重新加载初始数据时，重置状态
        _noMoreHistory = false;
        _onNoMoreHistoryChanged?.call(false);
      }

      _onCandlesChanged?.call(_candles);
      _onInitialLoadStateChanged?.call(_initialLoadState);

      if (candleList.isNotEmpty) {
        _onPriceChanged?.call(
          candleList.last.close,
          (candleList.last.epoch / 1000).toInt(),
        );
      }
    } catch (error, stackTrace) {
      logger.e(error, stackTrace: stackTrace);
      if (error is DioException && error.type == DioExceptionType.cancel) {
        return;
      }
      _initialLoadState = UiState.failure(
        fallback: isRefresh,
        error,
        retry: () => _loadDataWithSocketSync(),
      );
      _onInitialLoadStateChanged?.call(_initialLoadState);
    }
  }

  /// 检查数据断层风险
  void _checkAndHandleDataGap() {
    if (_socketConnectedTime == null || _apiDataReceivedTime == null) return;

    // socket 可以比接口早连接，因为在接口返回之前，socket 的数据会缓存起来
    final gap = _socketConnectedTime! - _apiDataReceivedTime!;
    final allowedGap = min(granularityMs * 2, _maxAllowedGapMs);

    if (gap > allowedGap) {
      logger.d(
        'CandleDataSynchronizer: 数据可能存在断层，间隔=${gap}ms，允许=${allowedGap}ms',
      );

      refreshData();
    } else {
      logger.d(
        'CandleDataSynchronizer: 数据同步正常，间隔=${gap}ms，允许=${allowedGap}ms',
      );
    }
  }

  /// 处理实时价格数据
  void _onPriceData(ManicPriceData priceData) {
    if (_isDisposed || !_isStarted) return;

    // 如果初始数据还在加载中或者加载失败，先缓存起来
    if (_initialLoadState.isLoading || _initialLoadState.isFailure) {
      _cachePriceData(priceData);
      return;
    }

    // 数据已初始化完毕，直接更新

    // 通知价格变化
    _onPriceChanged?.call(priceData.close, priceData.beat);

    // 将 ManicPriceData 转换为 Candle
    final newCandle = priceData.toDerivCandle();
    // 检查是否是更新现有蜡烛还是添加新蜡烛
    if (_candles.isNotEmpty && _candles.last.epoch == newCandle.epoch) {
      // 更新最后一根蜡烛 - 先修改原 list，再浅拷贝
      _candles[_candles.length - 1] = newCandle;
    } else {
      // 添加新蜡烛
      _candles.add(newCandle);
    }
    _onCandlesChanged?.call(_candles.toList());
  }

  /// 缓存价格数据
  void _cachePriceData(ManicPriceData priceData) {
    final existingData = _pendingPriceCache[priceData.timestamp];
    if (existingData == null || priceData.beat > existingData.beat) {
      _pendingPriceCache[priceData.timestamp] = priceData;
    }
  }

  /// 合并缓存的实时数据到历史K线数据
  List<Candle> _mergePendingPriceData(List<Candle> candleList) {
    if (_pendingPriceCache.isEmpty) return candleList;

    // 如果历史数据为空，直接用缓存的实时数据
    if (candleList.isEmpty) {
      final sortedPendingData = _pendingPriceCache.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return sortedPendingData.map((p) => p.toDerivCandle()).toList();
    }

    final result = candleList.toList();

    // 按 timestamp 排序处理缓存数据
    final sortedPendingData = _pendingPriceCache.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (final priceData in sortedPendingData) {
      final epochMs = priceData.timestamp * 1000;
      final lastCandle = result.last;

      if (lastCandle.epoch == epochMs) {
        // 更新最后一根蜡烛
        result[result.length - 1] = Candle(
          epoch: epochMs,
          open: lastCandle.open,
          high: max(lastCandle.high, priceData.high),
          low: min(lastCandle.low, priceData.low),
          close: priceData.close,
          currentEpoch: priceData.beat * 1000,
        );
      } else if (epochMs > lastCandle.epoch) {
        // 添加新蜡烛
        result.add(priceData.toDerivCandle());
      }
    }

    return result;
  }

  /// 刷新数据
  Future<void> refreshData() async {
    if (_isDisposed || !_isStarted) return;

    // 不依赖 isLive 状态判断：isConnected.value 只在收到 WS 事件时更新，
    // 存在僵尸连接（TCP 静默断开）时 isLive 可能滞后返回 true。
    // 统一走全量重同步，socket 在线时 connectReady 会立即返回，开销极小。
    logger.d('CandleDataSynchronizer: 刷新数据，重新同步 socket 和接口');
    _loadDataWithSocketSync(sequential: true, isRefresh: true);
  }
}
