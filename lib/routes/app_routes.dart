part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const String main = _Paths.main;
  static const String welcome = _Paths.welcome;
  static const String settings = _Paths.settings;
  static const String transactions = _Paths.transactions;
}

abstract class RouteNames {
  static const String receive = '/receive';
  static const String transfer = '/transfer';
  static const String transferAddress = '/transfer-address';
  static const List<String> transactionProcessRoutes = [
    transfer,
    transferAddress
  ];

  static const String profitLossShare = '/profit-loss-share';
  static const String highlowPayoutMultiplierSettings =
      '/highlow-payout-multiplier-settings';
}

abstract class _Paths {
  static const String main = '/index';
  static const String welcome = '/welcome';
  static const String settings = '/settings';
  static const String transactions = '/transactions';
}
