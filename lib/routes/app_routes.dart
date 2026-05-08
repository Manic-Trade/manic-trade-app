part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const String main = _Paths.main;
  static const String welcome = _Paths.welcome;
  static const String settings = _Paths.settings;
  static const String transactions = _Paths.transactions;
  static const String referralCode = _Paths.referralCode;
}

abstract class RouteNames {
  static const String receive = '/receive';
  static const String transfer = '/transfer';
  static const String transferAddress = '/transfer-address';
  static const String manageTokens = '/manage-tokens';
  static const String accountRentRecovery = '/account-rent-recovery';
  static const String swapSettings = '/swap-settings';
  static const String klineTimeBarSettings = '/kline-timeBar-settings';
  static const List<String> transactionProcessRoutes = [
    transfer,
    transferAddress
  ];
  static const List<String> accountRentRecoveryProcessRoutes = [
    manageTokens,
    accountRentRecovery
  ];
  static const String profitLossShare = '/profit-loss-share';
  static const String klineSettings = '/kline-settings';
  static const String highlowPayoutMultiplierSettings =
      '/highlow-payout-multiplier-settings';
}

abstract class _Paths {
  static const String main = '/index';
  static const String welcome = '/welcome';
  static const String settings = '/settings';
  static const String transactions = '/transactions';
  static const String referralCode = '/referral-code';
}
