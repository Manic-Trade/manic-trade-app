import 'dart:async';

import 'package:finality/core/logger.dart';
import 'package:finality/core/notifier/computed_notifier.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/model/ua/ua_models.dart';
import 'package:finality/data/network/ua_data_source.dart';
import 'package:finality/di/injector.dart';
import 'package:flutter/material.dart';
import 'package:store_scope/store_scope.dart';

final depositVMProvider = ViewModelProvider<DepositVM>((ref) {
  return DepositVM(injector<UADataSource>());
});

class DepositVM extends ViewModel {
  DepositVM(this._dataSource);

  final UADataSource _dataSource;

  /// 数据加载状态（chains + account）
  final ValueNotifier<UiState<bool>> dataState =
      ValueNotifier(UiState.loading());

  /// Sweep 状态（独立于数据加载）
  final ValueNotifier<UiState<UASweepData>> sweepState =
      ValueNotifier(UiState.initial());

  final ValueNotifier<List<UAChain>> chains = ValueNotifier([]);
  final ValueNotifier<UAAccountData?> account = ValueNotifier(null);

  /// 当前选中的链下标
  final ValueNotifier<int> selectedChainIndex = ValueNotifier(0);

  /// 当前选中的 Token 下标
  final ValueNotifier<int> selectedTokenIndex = ValueNotifier(0);

  // ── 计算派生状态（响应式，链式依赖）─────────────────────────

  /// 当前选中的链
  late final selectedChainNotifier =
      chains.computed2(selectedChainIndex, (list, idx) {
    if (list.isEmpty || idx >= list.length) return null;
    return list[idx];
  });

  /// 当前链的 token 列表
  late final tokens = selectedChainNotifier
      .computed((chain) => chain?.assetList ?? <UAAsset>[]);

  /// 当前选中的 token
  late final selectedTokenNotifier =
      tokens.computed2(selectedTokenIndex, (list, idx) {
    if (list.isEmpty || idx >= list.length) return null;
    return list[idx];
  });

  /// 当前充值地址（随链切换自动更新）
  late final depositAddressNotifier =
      selectedChainNotifier.computed2(account, (chain, acc) {
    if (acc == null || chain == null) return '';
    return chain.isEvm ? acc.ua.evmAddress : acc.ua.solanaAddress;
  });

  /// 当前 token 图标
  late final tokenIconNotifier =
      selectedTokenNotifier.computed((token) => token?.icon ?? '');

  Timer? _pollingTimer;
  bool _isSweeping = false;

  // ── 便捷 getter ──────────────────────────────────────────

  UAChain? get selectedChain => selectedChainNotifier.value;

  UAAsset? get selectedToken => selectedTokenNotifier.value;

  String get depositAddress => depositAddressNotifier.value;

  /// 当前链的最低充值金额（暂时固定 $10，与 web 端一致）
  int get minDeposit => 10;

  // ── 生命周期 ──────────────────────────────────────────────

  @override
  void init() {
    super.init();
    _loadInitialData();
  }

  @override
  void dispose() {
    _stopPolling();
    // 先 dispose 计算值（依赖源），再 dispose 源
    tokenIconNotifier.dispose();
    depositAddressNotifier.dispose();
    selectedTokenNotifier.dispose();
    tokens.dispose();
    selectedChainNotifier.dispose();
    dataState.dispose();
    sweepState.dispose();
    chains.dispose();
    account.dispose();
    selectedChainIndex.dispose();
    selectedTokenIndex.dispose();
    super.dispose();
  }

  // ── 数据加载 ──────────────────────────────────────────────

  Future<void> _loadInitialData() async {
    dataState.value = UiState.loading();
    try {
      // 并发请求 assets 和 account
      final results = await Future.wait([
        _dataSource.getAssets(),
        _dataSource.getAccount(),
      ]);
      chains.value = results[0] as List<UAChain>;
      account.value = results[1] as UAAccountData;
      dataState.value = UiState.success(true);
      _startPolling();
    } catch (e, st) {
      logger.e('DepositVM: 初始化失败', error: e, stackTrace: st);
      dataState.value = UiState.failure(e, retry: retry);
    }
  }

  // ── 选择操作 ──────────────────────────────────────────────

  void selectChain(int index) {
    selectedChainIndex.value = index;
    selectedTokenIndex.value = 0; // 切链后重置 token 选择
  }

  void selectToken(int index) {
    selectedTokenIndex.value = index;
  }

  // ── 轮询逻辑 ──────────────────────────────────────────────

  void _startPolling() {
    logger.d('DepositVM: 开始轮询余额，间隔 5s');
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_isSweeping) {
        logger.d('DepositVM: 正在 sweep 中，跳过本次轮询');
        return;
      }
      try {
        final balanceData = await _dataSource.getBalance();
        final balance = balanceData.balance;
        final largestAsset = balance.largestAsset;
        logger.d(
          'DepositVM: 轮询结果 - largestAsset: ${largestAsset?.tokenType}, '
          'amountInUSD: ${largestAsset?.amountInUSD}, '
          'minProcess: ${balance.minProcess}',
        );
        if (largestAsset != null &&
            largestAsset.amountInUSD > balance.minProcess &&
            !_isSweeping) {
          logger.d(
            'DepositVM: 余额满足条件，触发 sweep - '
            '${largestAsset.tokenType} \$${largestAsset.amountInUSD} > \$${balance.minProcess}',
          );
          _isSweeping = true;
          sweepState.value = UiState.loading();
          await _executeSweep();
        }
      } catch (e) {
        // 静默失败，继续下次轮询
        logger.w('DepositVM: 轮询余额失败: $e');
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _executeSweep() async {
    try {
      final result = await _dataSource.executeSweep();
      _stopPolling();
      sweepState.value = UiState.success(result);
      logger.d('DepositVM: Sweep 成功，txHash=${result.solanaTxHash}');
    } catch (e, st) {
      logger.e('DepositVM: Sweep 失败', error: e, stackTrace: st);
      _isSweeping = false;
      sweepState.value = UiState.initial();
      // 下次轮询可重试
    }
  }

  // ── 重试 ──────────────────────────────────────────────────

  void retry() {
    _loadInitialData();
  }
}
