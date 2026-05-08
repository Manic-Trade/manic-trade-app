import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:finality/common/utils/string_extensions.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/notifier/computed_notifier.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/ua_data_source.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/auth/user_profile_store.dart';
import 'package:finality/domain/wallet/entities/unified_wallet_accounts.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/wallet/token_position_service.dart';
import 'package:flutter/foundation.dart';
import 'package:store_scope/store_scope.dart';

final userViewModelProvider = ViewModelProvider(
  (space) => UserViewModel(
    injector<TokenPositionService>(),
    injector<UADataSource>(),
    injector<ManicTradeDataSource>(),
    injector<TurnkeyManager>(),
    injector<UserProfileStore>(),
  ),
);

class UserViewModel extends ViewModel {
  UserViewModel(
    this._tokenPositionService,
    this._uaDataSource,
    this._manicTradeDataSource,
    this._turnkeyManager,
    this._profileStore,
  );

  final TokenPositionService _tokenPositionService;
  final UADataSource _uaDataSource;
  final ManicTradeDataSource _manicTradeDataSource;
  final TurnkeyManager _turnkeyManager;
  final UserProfileStore _profileStore;

  ValueListenable<double> get totalAssetValue =>
      _tokenPositionService.totalAssetValue;

  ValueNotifier<UnifiedWalletAccounts?> get walletAccounts =>
      _tokenPositionService.walletAccounts;

  final _selectedTabIndex = ValueNotifier<int>(0); // 0=Demo, 1=Real

  ValueListenable<int> get selectedTabIndex => _selectedTabIndex;

  void setAccountType(bool isReal) {
    if (_selectedTabIndex.value == (isReal ? 1 : 0)) return;
    _selectedTabIndex.value = isReal ? 1 : 0;
    var currentBalanceState = _realBalanceState.value;
    if (currentBalanceState.isInitial || currentBalanceState.isFailure) {
      fetchRealBalance(false);
    }
  }

  final ValueNotifier<UiState<double>> _realBalanceState =
      ValueNotifier(UiState.initial());

  ValueListenable<UiState<double>> get realBalanceState => _realBalanceState;

  /// X 登录用户的真 @handle（来自后端 /users/twitter/status），其他登录方式为 null。
  /// 用 UserProfileStore 里的缓存做种子，首帧立即展示；init 时后台再拉一次更新。
  late final ValueNotifier<String?> _twitterName =
      ValueNotifier(_profileStore.twitterName);

  /// UID 展示文案：优先级 X @handle > 外部登录钱包 > email > Turnkey userName。
  /// 设计上三条登录路径互斥：Web3 必有 loginWalletAddress，OAuth/Email 必为空，
  /// 所以实际展示的就是"用户登录用的凭证"。email 取自 TurnkeyManager、
  /// 登录钱包地址取自 UserProfileStore，均在登录/登出时更新，登录后 VM 生命周期
  /// 内稳定，因此只监听 walletAccounts + twitterName。
  late final ValueListenable<String?> uidText = walletAccounts.computed2(
    _twitterName,
    (accounts, twitterName) => _buildUidText(
      twitterName: twitterName,
      loginWalletAddress: _profileStore.loginWalletAddress,
      turnkeyManager: _turnkeyManager,
    ),
  );

  /// UID 显示优先级：X @handle > 外部登录钱包 > email > Turnkey userName。
  /// Turnkey 占位符（形如 `user-xxxxxxxx`，后端 TWITTER_BEARER_TOKEN 额度耗尽时的 fallback）
  /// 视为没拿到真 handle，走下一级兜底。
  String? _buildUidText({
    String? twitterName,
    String? loginWalletAddress,
    required TurnkeyManager turnkeyManager,
  }) {
    final hasRealHandle = twitterName != null &&
        twitterName.isNotEmpty &&
        !twitterName.startsWith('user-');
    if (hasRealHandle) return 'UID: @$twitterName';
    if (loginWalletAddress != null && loginWalletAddress.isNotEmpty) {
      return 'UID: ${loginWalletAddress.truncateWithEllipsis(
        prefixLength: 4,
        suffixLength: 4,
      )}';
    }
    var turnKeyUser = turnkeyManager.user;
    if (turnKeyUser != null) {
      final userEmail = turnkeyManager.user?.userEmail;
      if (userEmail != null && userEmail.isNotEmpty) return userEmail;
      return 'UID: ${turnKeyUser.userName}';
    }

    return null;
  }

  @override
  void init() {
    super.init();
    _loadTwitterName();
  }

  /// 拉取后端保存的 X @handle。非 X 登录用户接口会返回 twitter_name: null，
  /// 失败静默，不弹 toast（显示侧有 email/wallet 兜底）。
  /// 拉到的值同时写入 UserProfileStore，下次进入可用缓存直出。
  Future<void> _loadTwitterName() async {
    final xProvider =
        _turnkeyManager.user?.oauthProviders.firstWhereOrNull((p) {
      final n = p.providerName.toLowerCase();
      return n.contains('x') || n.contains('twitter');
    });
    if (xProvider == null) return;
    final wallet = walletAccounts.value?.getSolanaAccount()?.address;
    if (wallet == null || wallet.isEmpty) return;
    try {
      final resp = await _manicTradeDataSource.getTwitterStatus(wallet);
      _twitterName.value = resp.twitterName;
      _profileStore.twitterName = resp.twitterName;
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
    }
  }

  /// 切换到 Real tab 时调用，获取真实 USDC 余额
  Future<void> fetchRealBalance(bool isRefresh) async {
    var currentState = _realBalanceState.value;
    // 刷新时用 toLoading 保留旧值作为 fallback，首次加载用纯 loading
    _realBalanceState.value =
        isRefresh ? currentState.toLoading() : UiState.loading();
    try {
      final data = await _uaDataSource.getSolanaBalance();
      _realBalanceState.value = UiState.success(data.usdcBalance);
    } catch (e, stackTrace) {
      logger.e("fetchRealBalance", error: e, stackTrace: stackTrace);
      _realBalanceState.value =
          currentState.toFailure(e, retry: () => fetchRealBalance(isRefresh));
    }
  }

  Future<void> handleCallRefresh() async {
    if (_selectedTabIndex.value == 1) {
      await fetchRealBalance(true);
    } else {
      await _tokenPositionService.fetchCurrentAccountsTokenPositions();
    }
  }
}
