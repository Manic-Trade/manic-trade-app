// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Time`
  String get k_tooltipTime {
    return Intl.message('Time', name: 'k_tooltipTime', desc: '', args: []);
  }

  /// `Open`
  String get k_tooltipOpen {
    return Intl.message('Open', name: 'k_tooltipOpen', desc: '', args: []);
  }

  /// `High`
  String get k_tooltipHigh {
    return Intl.message('High', name: 'k_tooltipHigh', desc: '', args: []);
  }

  /// `Low`
  String get k_tooltipLow {
    return Intl.message('Low', name: 'k_tooltipLow', desc: '', args: []);
  }

  /// `Close`
  String get k_tooltipClose {
    return Intl.message('Close', name: 'k_tooltipClose', desc: '', args: []);
  }

  /// `Chg`
  String get k_tooltipChg {
    return Intl.message('Chg', name: 'k_tooltipChg', desc: '', args: []);
  }

  /// `%Chg`
  String get k_tooltipChgRate {
    return Intl.message('%Chg', name: 'k_tooltipChgRate', desc: '', args: []);
  }

  /// `Range`
  String get k_tooltipRange {
    return Intl.message('Range', name: 'k_tooltipRange', desc: '', args: []);
  }

  /// `Amount`
  String get k_tooltipAmount {
    return Intl.message('Amount', name: 'k_tooltipAmount', desc: '', args: []);
  }

  /// `Turnover`
  String get k_tooltipTurnover {
    return Intl.message(
      'Turnover',
      name: 'k_tooltipTurnover',
      desc: '',
      args: [],
    );
  }

  /// `Indicators`
  String get k_indicators {
    return Intl.message('Indicators', name: 'k_indicators', desc: '', args: []);
  }

  /// `24h high`
  String get k_h24_high {
    return Intl.message('24h high', name: 'k_h24_high', desc: '', args: []);
  }

  /// `24h low`
  String get k_h24_low {
    return Intl.message('24h low', name: 'k_h24_low', desc: '', args: []);
  }

  /// `24h vol({unit})`
  String k_h24_vol(Object unit) {
    return Intl.message(
      '24h vol($unit)',
      name: 'k_h24_vol',
      desc: '',
      args: [unit],
    );
  }

  /// `24h turnover({unit})`
  String k_h24_turnover(Object unit) {
    return Intl.message(
      '24h turnover($unit)',
      name: 'k_h24_turnover',
      desc: '',
      args: [unit],
    );
  }

  /// `Chart settings`
  String get k_chartSettings {
    return Intl.message(
      'Chart settings',
      name: 'k_chartSettings',
      desc: '',
      args: [],
    );
  }

  /// `Landscape`
  String get k_landscape {
    return Intl.message('Landscape', name: 'k_landscape', desc: '', args: []);
  }

  /// `Drawings`
  String get k_drawings {
    return Intl.message('Drawings', name: 'k_drawings', desc: '', args: []);
  }

  /// `More`
  String get k_more {
    return Intl.message('More', name: 'k_more', desc: '', args: []);
  }

  /// `Last price`
  String get k_lastPrice {
    return Intl.message('Last price', name: 'k_lastPrice', desc: '', args: []);
  }

  /// `Price scale(y-axis)`
  String get k_yAxisPriceScale {
    return Intl.message(
      'Price scale(y-axis)',
      name: 'k_yAxisPriceScale',
      desc: '',
      args: [],
    );
  }

  /// `Countdown`
  String get k_countdown {
    return Intl.message('Countdown', name: 'k_countdown', desc: '', args: []);
  }

  /// `Chart Height`
  String get k_chartHeight {
    return Intl.message(
      'Chart Height',
      name: 'k_chartHeight',
      desc: '',
      args: [],
    );
  }

  /// `Chart Width`
  String get k_chartWidth {
    return Intl.message(
      'Chart Width',
      name: 'k_chartWidth',
      desc: '',
      args: [],
    );
  }

  /// `High Price`
  String get k_highPrice {
    return Intl.message('High Price', name: 'k_highPrice', desc: '', args: []);
  }

  /// `Low Price`
  String get k_lowPrice {
    return Intl.message('Low Price', name: 'k_lowPrice', desc: '', args: []);
  }

  /// `Grid`
  String get k_grid_show {
    return Intl.message('Grid', name: 'k_grid_show', desc: '', args: []);
  }

  /// `Select Trading Pair`
  String get k_selectTradingPair {
    return Intl.message(
      'Select Trading Pair',
      name: 'k_selectTradingPair',
      desc: '',
      args: [],
    );
  }

  /// `Name/Vol`
  String get k_labelNameVol {
    return Intl.message('Name/Vol', name: 'k_labelNameVol', desc: '', args: []);
  }

  /// `Price`
  String get k_labelPrice {
    return Intl.message('Price', name: 'k_labelPrice', desc: '', args: []);
  }

  /// `24H Change`
  String get k_label24HChange {
    return Intl.message(
      '24H Change',
      name: 'k_label24HChange',
      desc: '',
      args: [],
    );
  }

  /// `Preferred intervals`
  String get k_preferredIntervals {
    return Intl.message(
      'Preferred intervals',
      name: 'k_preferredIntervals',
      desc: '',
      args: [],
    );
  }

  /// `Intervals`
  String get k_intervals {
    return Intl.message('Intervals', name: 'k_intervals', desc: '', args: []);
  }

  /// `Main-chart indicators`
  String get k_mainChartIndicators {
    return Intl.message(
      'Main-chart indicators',
      name: 'k_mainChartIndicators',
      desc: '',
      args: [],
    );
  }

  /// `Sub-chart indicators`
  String get k_subChartIndicators {
    return Intl.message(
      'Sub-chart indicators',
      name: 'k_subChartIndicators',
      desc: '',
      args: [],
    );
  }

  /// `Indicator settings`
  String get k_indicatorSetting {
    return Intl.message(
      'Indicator settings',
      name: 'k_indicatorSetting',
      desc: '',
      args: [],
    );
  }

  /// `Please enter preferred trading pair`
  String get k_searchTradingPairHint {
    return Intl.message(
      'Please enter preferred trading pair',
      name: 'k_searchTradingPairHint',
      desc: '',
      args: [],
    );
  }

  /// `Chart settings`
  String get k_title_chart_settings {
    return Intl.message(
      'Chart settings',
      name: 'k_title_chart_settings',
      desc: '',
      args: [],
    );
  }

  /// `Chart`
  String get k_title_chart_settings_short {
    return Intl.message(
      'Chart',
      name: 'k_title_chart_settings_short',
      desc: '',
      args: [],
    );
  }

  /// `Chart display`
  String get k_title_chart_display {
    return Intl.message(
      'Chart display',
      name: 'k_title_chart_display',
      desc: '',
      args: [],
    );
  }

  /// `Trading display`
  String get k_title_trading_display {
    return Intl.message(
      'Trading display',
      name: 'k_title_trading_display',
      desc: '',
      args: [],
    );
  }

  /// `Trade history`
  String get k_title_trade_history {
    return Intl.message(
      'Trade history',
      name: 'k_title_trade_history',
      desc: '',
      args: [],
    );
  }

  /// `Buy average`
  String get k_title_buy_average {
    return Intl.message(
      'Buy average',
      name: 'k_title_buy_average',
      desc: '',
      args: [],
    );
  }

  /// `Sell average`
  String get k_title_sell_average {
    return Intl.message(
      'Sell average',
      name: 'k_title_sell_average',
      desc: '',
      args: [],
    );
  }

  /// `Avg Buy:`
  String get k_title_avg_buy_price {
    return Intl.message(
      'Avg Buy:',
      name: 'k_title_avg_buy_price',
      desc: '',
      args: [],
    );
  }

  /// `Avg Sell:`
  String get k_title_avg_sell_price {
    return Intl.message(
      'Avg Sell:',
      name: 'k_title_avg_sell_price',
      desc: '',
      args: [],
    );
  }

  /// `Calculation period`
  String get k_title_calculation_period {
    return Intl.message(
      'Calculation period',
      name: 'k_title_calculation_period',
      desc: '',
      args: [],
    );
  }

  /// `MA period`
  String get k_title_ma_period {
    return Intl.message(
      'MA period',
      name: 'k_title_ma_period',
      desc: '',
      args: [],
    );
  }

  /// `Short period`
  String get k_title_short_period {
    return Intl.message(
      'Short period',
      name: 'k_title_short_period',
      desc: '',
      args: [],
    );
  }

  /// `Long period`
  String get k_title_long_period {
    return Intl.message(
      'Long period',
      name: 'k_title_long_period',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get action_reset {
    return Intl.message('Reset', name: 'action_reset', desc: '', args: []);
  }

  /// `Save`
  String get action_save {
    return Intl.message('Save', name: 'action_save', desc: '', args: []);
  }

  /// `Indicator Description`
  String get title_indicator_description {
    return Intl.message(
      'Indicator Description',
      name: 'title_indicator_description',
      desc: '',
      args: [],
    );
  }

  /// `EMA`
  String get title_indicator_ema {
    return Intl.message('EMA', name: 'title_indicator_ema', desc: '', args: []);
  }

  /// `EMA (Exponential Moving Average) is a technical indicator that smooths price data over a specific period, reflecting both short-term and long-term trends.`
  String get title_indicator_ema_description {
    return Intl.message(
      'EMA (Exponential Moving Average) is a technical indicator that smooths price data over a specific period, reflecting both short-term and long-term trends.',
      name: 'title_indicator_ema_description',
      desc: '',
      args: [],
    );
  }

  /// `MA`
  String get title_indicator_ma {
    return Intl.message('MA', name: 'title_indicator_ma', desc: '', args: []);
  }

  /// `MA (Moving Average) is a technical indicator that smooths price data over a specific period, reflecting both short-term and long-term trends.`
  String get title_indicator_ma_description {
    return Intl.message(
      'MA (Moving Average) is a technical indicator that smooths price data over a specific period, reflecting both short-term and long-term trends.',
      name: 'title_indicator_ma_description',
      desc: '',
      args: [],
    );
  }

  /// `RSI`
  String get title_indicator_rsi {
    return Intl.message('RSI', name: 'title_indicator_rsi', desc: '', args: []);
  }

  /// `RSI (Relative Strength Index) is a technical indicator that measures the speed and change of price movements, indicating overbought or oversold conditions.`
  String get title_indicator_rsi_description {
    return Intl.message(
      'RSI (Relative Strength Index) is a technical indicator that measures the speed and change of price movements, indicating overbought or oversold conditions.',
      name: 'title_indicator_rsi_description',
      desc: '',
      args: [],
    );
  }

  /// `MACD`
  String get title_indicator_macd {
    return Intl.message(
      'MACD',
      name: 'title_indicator_macd',
      desc: '',
      args: [],
    );
  }

  /// `MACD (Moving Average Convergence Divergence) is a technical indicator that measures the relationship between two moving averages of a security's price, indicating the momentum and trend of the price.`
  String get title_indicator_macd_description {
    return Intl.message(
      'MACD (Moving Average Convergence Divergence) is a technical indicator that measures the relationship between two moving averages of a security\'s price, indicating the momentum and trend of the price.',
      name: 'title_indicator_macd_description',
      desc: '',
      args: [],
    );
  }

  /// `BOLL`
  String get title_indicator_boll {
    return Intl.message(
      'BOLL',
      name: 'title_indicator_boll',
      desc: '',
      args: [],
    );
  }

  /// `BOLL (Bollinger Bands) is a technical indicator that measures the volatility of a security's price, indicating the upper and lower limits of the price range.`
  String get title_indicator_boll_description {
    return Intl.message(
      'BOLL (Bollinger Bands) is a technical indicator that measures the volatility of a security\'s price, indicating the upper and lower limits of the price range.',
      name: 'title_indicator_boll_description',
      desc: '',
      args: [],
    );
  }

  /// `VOL`
  String get title_indicator_vol {
    return Intl.message('VOL', name: 'title_indicator_vol', desc: '', args: []);
  }

  /// `VOL (Volume) is a technical indicator that measures the volume of a security's price, indicating the volume of the price.`
  String get title_indicator_vol_description {
    return Intl.message(
      'VOL (Volume) is a technical indicator that measures the volume of a security\'s price, indicating the volume of the price.',
      name: 'title_indicator_vol_description',
      desc: '',
      args: [],
    );
  }

  /// `SAR`
  String get title_indicator_sar {
    return Intl.message('SAR', name: 'title_indicator_sar', desc: '', args: []);
  }

  /// `SAR (Parabolic Stop and Reverse) is a technical indicator that measures the stop and reverse of a security's price, indicating the stop and reverse of the price.`
  String get title_indicator_sar_description {
    return Intl.message(
      'SAR (Parabolic Stop and Reverse) is a technical indicator that measures the stop and reverse of a security\'s price, indicating the stop and reverse of the price.',
      name: 'title_indicator_sar_description',
      desc: '',
      args: [],
    );
  }

  /// `KDJ`
  String get title_indicator_kdj {
    return Intl.message('KDJ', name: 'title_indicator_kdj', desc: '', args: []);
  }

  /// `KDJ (Stochastic Oscillator) is a technical indicator that measures the speed and change of price movements, indicating overbought or oversold conditions.`
  String get title_indicator_kdj_description {
    return Intl.message(
      'KDJ (Stochastic Oscillator) is a technical indicator that measures the speed and change of price movements, indicating overbought or oversold conditions.',
      name: 'title_indicator_kdj_description',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Wallet`
  String get title_wallet {
    return Intl.message('Wallet', name: 'title_wallet', desc: '', args: []);
  }

  /// `Settings`
  String get title_settings {
    return Intl.message('Settings', name: 'title_settings', desc: '', args: []);
  }

  /// `Activity`
  String get title_activity {
    return Intl.message('Activity', name: 'title_activity', desc: '', args: []);
  }

  /// `Accounts`
  String get title_accounts {
    return Intl.message('Accounts', name: 'title_accounts', desc: '', args: []);
  }

  /// `Account`
  String get title_account {
    return Intl.message('Account', name: 'title_account', desc: '', args: []);
  }

  /// `Transactions`
  String get title_transactions {
    return Intl.message(
      'Transactions',
      name: 'title_transactions',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get title_home {
    return Intl.message('Home', name: 'title_home', desc: '', args: []);
  }

  /// `Language`
  String get title_language_setting {
    return Intl.message(
      'Language',
      name: 'title_language_setting',
      desc: '',
      args: [],
    );
  }

  /// `Currency`
  String get title_currency_unit {
    return Intl.message(
      'Currency',
      name: 'title_currency_unit',
      desc: '',
      args: [],
    );
  }

  /// `Recovery phrase`
  String get title_recovery_phrase {
    return Intl.message(
      'Recovery phrase',
      name: 'title_recovery_phrase',
      desc: '',
      args: [],
    );
  }

  /// `Rate us`
  String get title_rate_us {
    return Intl.message('Rate us', name: 'title_rate_us', desc: '', args: []);
  }

  /// `Share with Friends`
  String get title_share_with_friends {
    return Intl.message(
      'Share with Friends',
      name: 'title_share_with_friends',
      desc: '',
      args: [],
    );
  }

  /// `Help & Support`
  String get title_help_and_support {
    return Intl.message(
      'Help & Support',
      name: 'title_help_and_support',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get title_theme {
    return Intl.message('Theme', name: 'title_theme', desc: '', args: []);
  }

  /// `Security`
  String get title_security {
    return Intl.message('Security', name: 'title_security', desc: '', args: []);
  }

  /// `Preferences`
  String get title_preferences {
    return Intl.message(
      'Preferences',
      name: 'title_preferences',
      desc: '',
      args: [],
    );
  }

  /// `My Accounts`
  String get title_my_accounts {
    return Intl.message(
      'My Accounts',
      name: 'title_my_accounts',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get title_about {
    return Intl.message('About', name: 'title_about', desc: '', args: []);
  }

  /// `Terms of use`
  String get title_terms_of_use {
    return Intl.message(
      'Terms of use',
      name: 'title_terms_of_use',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get title_privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'title_privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Backed up`
  String get message_backed_up {
    return Intl.message(
      'Backed up',
      name: 'message_backed_up',
      desc: '',
      args: [],
    );
  }

  /// `Not backed up`
  String get message_not_backed_up {
    return Intl.message(
      'Not backed up',
      name: 'message_not_backed_up',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get theme_light {
    return Intl.message('Light', name: 'theme_light', desc: '', args: []);
  }

  /// `Dark`
  String get theme_dark {
    return Intl.message('Dark', name: 'theme_dark', desc: '', args: []);
  }

  /// `System`
  String get follow_system {
    return Intl.message('System', name: 'follow_system', desc: '', args: []);
  }

  /// `About us`
  String get about_us {
    return Intl.message('About us', name: 'about_us', desc: '', args: []);
  }

  /// `Are you sure you want to delete the backup from the cloud storage service? You can always back up again.`
  String get title_dialog_delete_cloud_backup {
    return Intl.message(
      'Are you sure you want to delete the backup from the cloud storage service? You can always back up again.',
      name: 'title_dialog_delete_cloud_backup',
      desc: '',
      args: [],
    );
  }

  /// `Delete Record`
  String get action_delete_record {
    return Intl.message(
      'Delete Record',
      name: 'action_delete_record',
      desc: '',
      args: [],
    );
  }

  /// `Block Time`
  String get title_block_time {
    return Intl.message(
      'Block Time',
      name: 'title_block_time',
      desc: '',
      args: [],
    );
  }

  /// `In the next step, you will see the recovery phrase for restoring the wallet. Please be sure to protect it, don't lose it or get it by others.`
  String get message_mnemonic_show_warn {
    return Intl.message(
      'In the next step, you will see the recovery phrase for restoring the wallet. Please be sure to protect it, don\'t lose it or get it by others.',
      name: 'message_mnemonic_show_warn',
      desc: '',
      args: [],
    );
  }

  /// `In the next step, you will see your private key, it is equivalent to your account password. Please be sure to protect it, don't lose it or get it by others.`
  String get message_private_key_show_warn {
    return Intl.message(
      'In the next step, you will see your private key, it is equivalent to your account password. Please be sure to protect it, don\'t lose it or get it by others.',
      name: 'message_private_key_show_warn',
      desc: '',
      args: [],
    );
  }

  /// `Network`
  String get title_network {
    return Intl.message('Network', name: 'title_network', desc: '', args: []);
  }

  /// `Turn off fingerprint unlocking`
  String get turn_off_fingerprint_unlocking {
    return Intl.message(
      'Turn off fingerprint unlocking',
      name: 'turn_off_fingerprint_unlocking',
      desc: '',
      args: [],
    );
  }

  /// `Input incorrect`
  String get message_input_incorrect {
    return Intl.message(
      'Input incorrect',
      name: 'message_input_incorrect',
      desc: '',
      args: [],
    );
  }

  /// `Join Shared Account`
  String get title_join_shared_account {
    return Intl.message(
      'Join Shared Account',
      name: 'title_join_shared_account',
      desc: '',
      args: [],
    );
  }

  /// `Creator`
  String get flag_creator {
    return Intl.message('Creator', name: 'flag_creator', desc: '', args: []);
  }

  /// `Security level: strong`
  String get message_backup_cloud_tip_text2 {
    return Intl.message(
      'Security level: strong',
      name: 'message_backup_cloud_tip_text2',
      desc: '',
      args: [],
    );
  }

  /// `Risk are：\n• Your cloud storage service account has been stolen\n• You can't log in to your cloud storage service\n• You accidentally deleted backup files on cloud storage services\n• You have authorized other apps to access backup files on cloud storage services\n• Someone else got the backup file`
  String get message_backup_cloud_tip_text3 {
    return Intl.message(
      'Risk are：\n• Your cloud storage service account has been stolen\n• You can\'t log in to your cloud storage service\n• You accidentally deleted backup files on cloud storage services\n• You have authorized other apps to access backup files on cloud storage services\n• Someone else got the backup file',
      name: 'message_backup_cloud_tip_text3',
      desc: '',
      args: [],
    );
  }

  /// `Save backup files of your wallet to your personal cloud storage service`
  String get message_backup_cloud_tip_text1 {
    return Intl.message(
      'Save backup files of your wallet to your personal cloud storage service',
      name: 'message_backup_cloud_tip_text1',
      desc: '',
      args: [],
    );
  }

  /// `Tips：\n• Avoid theft of your cloud storage service account\n• Use a cloud storage service account just for backing up your wallet\n• Carefully control the scope of access to your cloud storage service by other applications\n• Do not save the backup file locally to avoid the backup file being discovered by others`
  String get message_backup_cloud_tip_text4 {
    return Intl.message(
      'Tips：\n• Avoid theft of your cloud storage service account\n• Use a cloud storage service account just for backing up your wallet\n• Carefully control the scope of access to your cloud storage service by other applications\n• Do not save the backup file locally to avoid the backup file being discovered by others',
      name: 'message_backup_cloud_tip_text4',
      desc: '',
      args: [],
    );
  }

  /// `Contract Address`
  String get flag_contract_address {
    return Intl.message(
      'Contract Address',
      name: 'flag_contract_address',
      desc: '',
      args: [],
    );
  }

  /// `Got it`
  String get i_know {
    return Intl.message('Got it', name: 'i_know', desc: '', args: []);
  }

  /// `No record`
  String get message_no_record {
    return Intl.message(
      'No record',
      name: 'message_no_record',
      desc: '',
      args: [],
    );
  }

  /// `Your wallet token has expired and you need to refresh it.`
  String get message_token_has_expired_detail {
    return Intl.message(
      'Your wallet token has expired and you need to refresh it.',
      name: 'message_token_has_expired_detail',
      desc: '',
      args: [],
    );
  }

  /// `Your login state has expired, please log in again.`
  String get message_logout_has_expired_detail {
    return Intl.message(
      'Your login state has expired, please log in again.',
      name: 'message_logout_has_expired_detail',
      desc: '',
      args: [],
    );
  }

  /// `Transfer tokens from your Wallet account or elsewhere`
  String get message_no_coins_found_detail {
    return Intl.message(
      'Transfer tokens from your Wallet account or elsewhere',
      name: 'message_no_coins_found_detail',
      desc: '',
      args: [],
    );
  }

  /// `your code`
  String get hint_email_code {
    return Intl.message(
      'your code',
      name: 'hint_email_code',
      desc: '',
      args: [],
    );
  }

  /// `Back up manually`
  String get action_back_up_manually {
    return Intl.message(
      'Back up manually',
      name: 'action_back_up_manually',
      desc: '',
      args: [],
    );
  }

  /// `Staked`
  String get title_staking_staked {
    return Intl.message(
      'Staked',
      name: 'title_staking_staked',
      desc: '',
      args: [],
    );
  }

  /// `Weeks`
  String get weeks {
    return Intl.message('Weeks', name: 'weeks', desc: '', args: []);
  }

  /// `Recovery succeeded`
  String get message_restore_succeeded {
    return Intl.message(
      'Recovery succeeded',
      name: 'message_restore_succeeded',
      desc: '',
      args: [],
    );
  }

  /// `Transaction status`
  String get title_transaction_status {
    return Intl.message(
      'Transaction status',
      name: 'title_transaction_status',
      desc: '',
      args: [],
    );
  }

  /// `Backup recovery phrase`
  String get title_backup_mnemonic {
    return Intl.message(
      'Backup recovery phrase',
      name: 'title_backup_mnemonic',
      desc: '',
      args: [],
    );
  }

  /// `Import an existing wallet or create a new one`
  String get message_import_or_create_wallet {
    return Intl.message(
      'Import an existing wallet or create a new one',
      name: 'message_import_or_create_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Receive network`
  String get title_receive_network {
    return Intl.message(
      'Receive network',
      name: 'title_receive_network',
      desc: '',
      args: [],
    );
  }

  /// `Switch network`
  String get action_switch_network {
    return Intl.message(
      'Switch network',
      name: 'action_switch_network',
      desc: '',
      args: [],
    );
  }

  /// `Get tokens`
  String get action_get_coins {
    return Intl.message(
      'Get tokens',
      name: 'action_get_coins',
      desc: '',
      args: [],
    );
  }

  /// `Scan Result`
  String get title_scan_result {
    return Intl.message(
      'Scan Result',
      name: 'title_scan_result',
      desc: '',
      args: [],
    );
  }

  /// `Transaction complete`
  String get message_transaction_complete {
    return Intl.message(
      'Transaction complete',
      name: 'message_transaction_complete',
      desc: '',
      args: [],
    );
  }

  /// `Receiving`
  String get transaction_action_receiving {
    return Intl.message(
      'Receiving',
      name: 'transaction_action_receiving',
      desc: '',
      args: [],
    );
  }

  /// `Copied Txid`
  String get message_copied_transaction_hash {
    return Intl.message(
      'Copied Txid',
      name: 'message_copied_transaction_hash',
      desc: '',
      args: [],
    );
  }

  /// `Write down the words in the correct order and keep them in a safe place.`
  String get message_mnemonic_show_introduce {
    return Intl.message(
      'Write down the words in the correct order and keep them in a safe place.',
      name: 'message_mnemonic_show_introduce',
      desc: '',
      args: [],
    );
  }

  /// `Do not share your private key! If someone gets your private key, they can completely control your wallet.`
  String get message_private_key_show_introduce {
    return Intl.message(
      'Do not share your private key! If someone gets your private key, they can completely control your wallet.',
      name: 'message_private_key_show_introduce',
      desc: '',
      args: [],
    );
  }

  /// `Claim Rewards`
  String get title_claim_rewards {
    return Intl.message(
      'Claim Rewards',
      name: 'title_claim_rewards',
      desc: '',
      args: [],
    );
  }

  /// `Press again to exit`
  String get press_again_to_exit {
    return Intl.message(
      'Press again to exit',
      name: 'press_again_to_exit',
      desc: '',
      args: [],
    );
  }

  /// `Add failed, the node already exists`
  String get message_add_failed_network_node_already_exists {
    return Intl.message(
      'Add failed, the node already exists',
      name: 'message_add_failed_network_node_already_exists',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get business_status_failed {
    return Intl.message(
      'Failed',
      name: 'business_status_failed',
      desc: '',
      args: [],
    );
  }

  /// `Added successfully`
  String get message_added_successfully {
    return Intl.message(
      'Added successfully',
      name: 'message_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Networks Supported`
  String get flag_networks_supported {
    return Intl.message(
      'Networks Supported',
      name: 'flag_networks_supported',
      desc: '',
      args: [],
    );
  }

  /// `Deleted`
  String get deleted {
    return Intl.message('Deleted', name: 'deleted', desc: '', args: []);
  }

  /// `Network connected`
  String get network_state_connected {
    return Intl.message(
      'Network connected',
      name: 'network_state_connected',
      desc: '',
      args: [],
    );
  }

  /// `Select wallet type`
  String get title_select_wallet_type {
    return Intl.message(
      'Select wallet type',
      name: 'title_select_wallet_type',
      desc: '',
      args: [],
    );
  }

  /// `Copy URL`
  String get copy_url {
    return Intl.message('Copy URL', name: 'copy_url', desc: '', args: []);
  }

  /// `Days`
  String get days {
    return Intl.message('Days', name: 'days', desc: '', args: []);
  }

  /// `Retry`
  String get action_click_retry {
    return Intl.message(
      'Retry',
      name: 'action_click_retry',
      desc: '',
      args: [],
    );
  }

  /// `Switch account`
  String get title_switch_account {
    return Intl.message(
      'Switch account',
      name: 'title_switch_account',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get form_invalid_email_address {
    return Intl.message(
      'Invalid email address',
      name: 'form_invalid_email_address',
      desc: '',
      args: [],
    );
  }

  /// `Receive account`
  String get title_receive_account {
    return Intl.message(
      'Receive account',
      name: 'title_receive_account',
      desc: '',
      args: [],
    );
  }

  /// `Logout succeeded`
  String get message_logout_succeeded {
    return Intl.message(
      'Logout succeeded',
      name: 'message_logout_succeeded',
      desc: '',
      args: [],
    );
  }

  /// `Preparing to activate your account`
  String get message_preparing_activate_your_account {
    return Intl.message(
      'Preparing to activate your account',
      name: 'message_preparing_activate_your_account',
      desc: '',
      args: [],
    );
  }

  /// `Scan`
  String get action_scan {
    return Intl.message('Scan', name: 'action_scan', desc: '', args: []);
  }

  /// `Txid`
  String get subtitle_txid {
    return Intl.message('Txid', name: 'subtitle_txid', desc: '', args: []);
  }

  /// `Waiting for authorized copayers to join`
  String get message_shard_account_invitation_note {
    return Intl.message(
      'Waiting for authorized copayers to join',
      name: 'message_shard_account_invitation_note',
      desc: '',
      args: [],
    );
  }

  /// `Added`
  String get added {
    return Intl.message('Added', name: 'added', desc: '', args: []);
  }

  /// `Paste address`
  String get paste_address {
    return Intl.message(
      'Paste address',
      name: 'paste_address',
      desc: '',
      args: [],
    );
  }

  /// `Sell NFT`
  String get title_nft_sell {
    return Intl.message('Sell NFT', name: 'title_nft_sell', desc: '', args: []);
  }

  /// `Backup to OneDrive`
  String get message_format_add_cloud_backup_onedrive {
    return Intl.message(
      'Backup to OneDrive',
      name: 'message_format_add_cloud_backup_onedrive',
      desc: '',
      args: [],
    );
  }

  /// `Removed from favorites`
  String get message_removed_from_favorites {
    return Intl.message(
      'Removed from favorites',
      name: 'message_removed_from_favorites',
      desc: '',
      args: [],
    );
  }

  /// `About to show recovery phrase`
  String get title_about_show_secret_recovery_phrase {
    return Intl.message(
      'About to show recovery phrase',
      name: 'title_about_show_secret_recovery_phrase',
      desc: '',
      args: [],
    );
  }

  /// `Select words in the correct order.`
  String get message_select_words_correct_order {
    return Intl.message(
      'Select words in the correct order.',
      name: 'message_select_words_correct_order',
      desc: '',
      args: [],
    );
  }

  /// `DisConnect from cloud storage service`
  String get title_disConnect_from_cloud {
    return Intl.message(
      'DisConnect from cloud storage service',
      name: 'title_disConnect_from_cloud',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Pending`
  String get transaction_status_pending {
    return Intl.message(
      'Pending',
      name: 'transaction_status_pending',
      desc: '',
      args: [],
    );
  }

  /// `Needs confirmation`
  String get transaction_status_needs_confirmation {
    return Intl.message(
      'Needs confirmation',
      name: 'transaction_status_needs_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Secure Multi-Chain Wallet`
  String get title_secure_multi_chain_wallet {
    return Intl.message(
      'Secure Multi-Chain Wallet',
      name: 'title_secure_multi_chain_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get action_try_again {
    return Intl.message(
      'Try again',
      name: 'action_try_again',
      desc: '',
      args: [],
    );
  }

  /// `Successful transfer`
  String get message_successful_transfer {
    return Intl.message(
      'Successful transfer',
      name: 'message_successful_transfer',
      desc: '',
      args: [],
    );
  }

  /// `Select token`
  String get title_select_coin {
    return Intl.message(
      'Select token',
      name: 'title_select_coin',
      desc: '',
      args: [],
    );
  }

  /// `You can go to OpenSea to buy NFTs`
  String get message_nft_empty_detailed {
    return Intl.message(
      'You can go to OpenSea to buy NFTs',
      name: 'message_nft_empty_detailed',
      desc: '',
      args: [],
    );
  }

  /// `No more data`
  String get message_no_more {
    return Intl.message(
      'No more data',
      name: 'message_no_more',
      desc: '',
      args: [],
    );
  }

  /// `Owners`
  String get flag_nft_owners {
    return Intl.message('Owners', name: 'flag_nft_owners', desc: '', args: []);
  }

  /// `Paste`
  String get paste {
    return Intl.message('Paste', name: 'paste', desc: '', args: []);
  }

  /// `Sending`
  String get transaction_action_sending {
    return Intl.message(
      'Sending',
      name: 'transaction_action_sending',
      desc: '',
      args: [],
    );
  }

  /// `You can sign in to your {name} account on any device to recover your wallet.`
  String message_wallet_cloud_backed_up_detailed(Object name) {
    return Intl.message(
      'You can sign in to your $name account on any device to recover your wallet.',
      name: 'message_wallet_cloud_backed_up_detailed',
      desc: '',
      args: [name],
    );
  }

  /// `You have not entered any fingerprints, please go to the system settings to register your fingerprint`
  String get not_register_fingerprint {
    return Intl.message(
      'You have not entered any fingerprints, please go to the system settings to register your fingerprint',
      name: 'not_register_fingerprint',
      desc: '',
      args: [],
    );
  }

  /// `To address`
  String get edit_payee_wallet_address_hint {
    return Intl.message(
      'To address',
      name: 'edit_payee_wallet_address_hint',
      desc: '',
      args: [],
    );
  }

  /// `Check`
  String get action_check {
    return Intl.message('Check', name: 'action_check', desc: '', args: []);
  }

  /// `Everything is ready`
  String get message_everything_is_ready {
    return Intl.message(
      'Everything is ready',
      name: 'message_everything_is_ready',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get message_something_went_wrong {
    return Intl.message(
      'Something went wrong',
      name: 'message_something_went_wrong',
      desc: '',
      args: [],
    );
  }

  /// `Set up a recovery plan if you ever lose your phone or get a new one`
  String get message_backup_reminder {
    return Intl.message(
      'Set up a recovery plan if you ever lose your phone or get a new one',
      name: 'message_backup_reminder',
      desc: '',
      args: [],
    );
  }

  /// `Wallet address`
  String get wallet_address {
    return Intl.message(
      'Wallet address',
      name: 'wallet_address',
      desc: '',
      args: [],
    );
  }

  /// `Connect to cloud`
  String get title_connect_cloud {
    return Intl.message(
      'Connect to cloud',
      name: 'title_connect_cloud',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get transaction_action_unknown {
    return Intl.message(
      'Unknown',
      name: 'transaction_action_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Recovery Phrase`
  String get title_confirm_secret_recovery_phrase {
    return Intl.message(
      'Confirm Recovery Phrase',
      name: 'title_confirm_secret_recovery_phrase',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the code sent to`
  String get message_please_enter_code_sent_to {
    return Intl.message(
      'Please enter the code sent to',
      name: 'message_please_enter_code_sent_to',
      desc: '',
      args: [],
    );
  }

  /// `Add Account`
  String get action_add_account {
    return Intl.message(
      'Add Account',
      name: 'action_add_account',
      desc: '',
      args: [],
    );
  }

  /// `Choose node`
  String get title_choose_node {
    return Intl.message(
      'Choose node',
      name: 'title_choose_node',
      desc: '',
      args: [],
    );
  }

  /// `This is 12 word phrase you were given when you created your previous wallet.`
  String get message_wallet_import {
    return Intl.message(
      'This is 12 word phrase you were given when you created your previous wallet.',
      name: 'message_wallet_import',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get flag_delegate_amount {
    return Intl.message(
      'Amount',
      name: 'flag_delegate_amount',
      desc: '',
      args: [],
    );
  }

  /// `Free`
  String get message_free {
    return Intl.message('Free', name: 'message_free', desc: '', args: []);
  }

  /// `In progress`
  String get activities_state_in_progress {
    return Intl.message(
      'In progress',
      name: 'activities_state_in_progress',
      desc: '',
      args: [],
    );
  }

  /// `Claim Rewards`
  String get action_staking_claim_rewards {
    return Intl.message(
      'Claim Rewards',
      name: 'action_staking_claim_rewards',
      desc: '',
      args: [],
    );
  }

  /// `Switch Node`
  String get action_switch_node {
    return Intl.message(
      'Switch Node',
      name: 'action_switch_node',
      desc: '',
      args: [],
    );
  }

  /// `Import Wallet`
  String get import_wallet {
    return Intl.message(
      'Import Wallet',
      name: 'import_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Tokens`
  String get title_coins {
    return Intl.message('Tokens', name: 'title_coins', desc: '', args: []);
  }

  /// `Building`
  String get transaction_status_building {
    return Intl.message(
      'Building',
      name: 'transaction_status_building',
      desc: '',
      args: [],
    );
  }

  /// `Input current PIN code`
  String get Input_current_PIN {
    return Intl.message(
      'Input current PIN code',
      name: 'Input_current_PIN',
      desc: '',
      args: [],
    );
  }

  /// `Open URL?`
  String get message_dapp_open_url_doubt {
    return Intl.message(
      'Open URL?',
      name: 'message_dapp_open_url_doubt',
      desc: '',
      args: [],
    );
  }

  /// `View recovery phrase`
  String get action_view_secret_phrase {
    return Intl.message(
      'View recovery phrase',
      name: 'action_view_secret_phrase',
      desc: '',
      args: [],
    );
  }

  /// `Backup Now`
  String get action_backup_now {
    return Intl.message(
      'Backup Now',
      name: 'action_backup_now',
      desc: '',
      args: [],
    );
  }

  /// `Cloud backup files may have been lost!`
  String get message_backup_file_lost {
    return Intl.message(
      'Cloud backup files may have been lost!',
      name: 'message_backup_file_lost',
      desc: '',
      args: [],
    );
  }

  /// `Legal notice`
  String get title_legal_notice {
    return Intl.message(
      'Legal notice',
      name: 'title_legal_notice',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get title_history {
    return Intl.message('History', name: 'title_history', desc: '', args: []);
  }

  /// `Add an extra layer of security to keep your crypto safe.`
  String get message_protect_wallet {
    return Intl.message(
      'Add an extra layer of security to keep your crypto safe.',
      name: 'message_protect_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Risk warning`
  String get title_risk_warning {
    return Intl.message(
      'Risk warning',
      name: 'title_risk_warning',
      desc: '',
      args: [],
    );
  }

  /// `Share this invitation with the devices joining this account. Each copayer has their own recovery phrase.To recover funds stored in a Shared Wallet you will need the recovery phrase from each copayer.`
  String get message_shard_account_invitation {
    return Intl.message(
      'Share this invitation with the devices joining this account. Each copayer has their own recovery phrase.To recover funds stored in a Shared Wallet you will need the recovery phrase from each copayer.',
      name: 'message_shard_account_invitation',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get title_details {
    return Intl.message('Details', name: 'title_details', desc: '', args: []);
  }

  /// `Buy`
  String get action_nft_buy {
    return Intl.message('Buy', name: 'action_nft_buy', desc: '', args: []);
  }

  /// `Verify fingerprint`
  String get scanning_fingerprint {
    return Intl.message(
      'Verify fingerprint',
      name: 'scanning_fingerprint',
      desc: '',
      args: [],
    );
  }

  /// `Enter or paste address`
  String get hint_enter_or_paste_address {
    return Intl.message(
      'Enter or paste address',
      name: 'hint_enter_or_paste_address',
      desc: '',
      args: [],
    );
  }

  /// `yesterday`
  String get format_some_age_4 {
    return Intl.message(
      'yesterday',
      name: 'format_some_age_4',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to quit?`
  String get message_signout_sure {
    return Intl.message(
      'Are you sure you want to quit?',
      name: 'message_signout_sure',
      desc: '',
      args: [],
    );
  }

  /// `To`
  String get to_address {
    return Intl.message('To', name: 'to_address', desc: '', args: []);
  }

  /// `Completed`
  String get transaction_status_completed {
    return Intl.message(
      'Completed',
      name: 'transaction_status_completed',
      desc: '',
      args: [],
    );
  }

  /// `Just`
  String get format_some_age_1 {
    return Intl.message('Just', name: 'format_some_age_1', desc: '', args: []);
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message('Cancelled', name: 'cancelled', desc: '', args: []);
  }

  /// `After backing up your wallet to {name}, you can sign in to your {name} account on any device to recover your wallet.`
  String message_not_backed_up_detailed(Object name) {
    return Intl.message(
      'After backing up your wallet to $name, you can sign in to your $name account on any device to recover your wallet.',
      name: 'message_not_backed_up_detailed',
      desc: '',
      args: [name],
    );
  }

  /// `Turn on fingerprint unlocking`
  String get turn_on_fingerprint_unlocking {
    return Intl.message(
      'Turn on fingerprint unlocking',
      name: 'turn_on_fingerprint_unlocking',
      desc: '',
      args: [],
    );
  }

  /// `Backup to Dropbox`
  String get message_format_add_cloud_backup_dropbox {
    return Intl.message(
      'Backup to Dropbox',
      name: 'message_format_add_cloud_backup_dropbox',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `To`
  String get title_to {
    return Intl.message('To', name: 'title_to', desc: '', args: []);
  }

  /// `Assets can only be sent within the same network`
  String get message_account_receipt_note {
    return Intl.message(
      'Assets can only be sent within the same network',
      name: 'message_account_receipt_note',
      desc: '',
      args: [],
    );
  }

  /// `Wallet name`
  String get edit_wallet_name_floating_label {
    return Intl.message(
      'Wallet name',
      name: 'edit_wallet_name_floating_label',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your email to continue`
  String get message_please_confirm_your_email_to_continue {
    return Intl.message(
      'Please confirm your email to continue',
      name: 'message_please_confirm_your_email_to_continue',
      desc: '',
      args: [],
    );
  }

  /// `Wallet setup`
  String get title_wallet_setup {
    return Intl.message(
      'Wallet setup',
      name: 'title_wallet_setup',
      desc: '',
      args: [],
    );
  }

  /// `Mints`
  String get title_mints {
    return Intl.message('Mints', name: 'title_mints', desc: '', args: []);
  }

  /// `Activate`
  String get action_activate {
    return Intl.message(
      'Activate',
      name: 'action_activate',
      desc: '',
      args: [],
    );
  }

  /// `Delete Dropbox backup`
  String get message_format_remove_cloud_backup_dropbox {
    return Intl.message(
      'Delete Dropbox backup',
      name: 'message_format_remove_cloud_backup_dropbox',
      desc: '',
      args: [],
    );
  }

  /// `Gas Limit`
  String get gas_limit {
    return Intl.message('Gas Limit', name: 'gas_limit', desc: '', args: []);
  }

  /// `Swap`
  String get title_swap {
    return Intl.message('Swap', name: 'title_swap', desc: '', args: []);
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `Unavailable`
  String get message_unavailable {
    return Intl.message(
      'Unavailable',
      name: 'message_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Amount to be paid`
  String get flag_amount_to_be_paid {
    return Intl.message(
      'Amount to be paid',
      name: 'flag_amount_to_be_paid',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get transaction_status_unknown {
    return Intl.message(
      'Unknown',
      name: 'transaction_status_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create wallet`
  String get message_failed_create_wallet {
    return Intl.message(
      'Failed to create wallet',
      name: 'message_failed_create_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get action_retry {
    return Intl.message('Retry', name: 'action_retry', desc: '', args: []);
  }

  /// `Max`
  String get max {
    return Intl.message('Max', name: 'max', desc: '', args: []);
  }

  /// `Added to favorites`
  String get message_added_to_favorites {
    return Intl.message(
      'Added to favorites',
      name: 'message_added_to_favorites',
      desc: '',
      args: [],
    );
  }

  /// `Unstake`
  String get title_staking_unstake {
    return Intl.message(
      'Unstake',
      name: 'title_staking_unstake',
      desc: '',
      args: [],
    );
  }

  /// `Minimum Amount`
  String get title_staking_minimum_amount {
    return Intl.message(
      'Minimum Amount',
      name: 'title_staking_minimum_amount',
      desc: '',
      args: [],
    );
  }

  /// `Loading…`
  String get message_loading {
    return Intl.message(
      'Loading…',
      name: 'message_loading',
      desc: '',
      args: [],
    );
  }

  /// `Moving`
  String get transaction_action_moving {
    return Intl.message(
      'Moving',
      name: 'transaction_action_moving',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get title_restore {
    return Intl.message('Restore', name: 'title_restore', desc: '', args: []);
  }

  /// `Supports recovery phrase import for any wallet`
  String get message_restore_with_phrase_subtitle2 {
    return Intl.message(
      'Supports recovery phrase import for any wallet',
      name: 'message_restore_with_phrase_subtitle2',
      desc: '',
      args: [],
    );
  }

  /// `Set the market`
  String get flag_set_the_market {
    return Intl.message(
      'Set the market',
      name: 'flag_set_the_market',
      desc: '',
      args: [],
    );
  }

  /// `To:`
  String get title_to_with_colon {
    return Intl.message('To:', name: 'title_to_with_colon', desc: '', args: []);
  }

  /// `Information`
  String get title_information {
    return Intl.message(
      'Information',
      name: 'title_information',
      desc: '',
      args: [],
    );
  }

  /// `Backup succeeded`
  String get message_backup_succeeded {
    return Intl.message(
      'Backup succeeded',
      name: 'message_backup_succeeded',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get action_copy {
    return Intl.message('Copy', name: 'action_copy', desc: '', args: []);
  }

  /// `Block`
  String get title_block_height {
    return Intl.message(
      'Block',
      name: 'title_block_height',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get copied {
    return Intl.message('Copied', name: 'copied', desc: '', args: []);
  }

  /// `Address copied`
  String get message_address_copied {
    return Intl.message(
      'Address copied',
      name: 'message_address_copied',
      desc: '',
      args: [],
    );
  }

  /// `Address copied: {address}`
  String message_address_copied_with_colon(Object address) {
    return Intl.message(
      'Address copied: $address',
      name: 'message_address_copied_with_colon',
      desc: '',
      args: [address],
    );
  }

  /// `Ethereum address copied`
  String get message_ethereum_address_copied {
    return Intl.message(
      'Ethereum address copied',
      name: 'message_ethereum_address_copied',
      desc: '',
      args: [],
    );
  }

  /// `Lock method`
  String get title_lock_method {
    return Intl.message(
      'Lock method',
      name: 'title_lock_method',
      desc: '',
      args: [],
    );
  }

  /// `Set the price`
  String get flag_set_the_price {
    return Intl.message(
      'Set the price',
      name: 'flag_set_the_price',
      desc: '',
      args: [],
    );
  }

  /// `All your transfer activity will be displayed here`
  String get message_no_transfer_activity_detail {
    return Intl.message(
      'All your transfer activity will be displayed here',
      name: 'message_no_transfer_activity_detail',
      desc: '',
      args: [],
    );
  }

  /// `No suitable account found`
  String get message_no_suitable_account_found {
    return Intl.message(
      'No suitable account found',
      name: 'message_no_suitable_account_found',
      desc: '',
      args: [],
    );
  }

  /// `Common address`
  String get subtitle_address_book_Common_address {
    return Intl.message(
      'Common address',
      name: 'subtitle_address_book_Common_address',
      desc: '',
      args: [],
    );
  }

  /// `Please remember the PIN code, If you forget to be unable to login Touch`
  String get Please_keep_pin {
    return Intl.message(
      'Please remember the PIN code, If you forget to be unable to login Touch',
      name: 'Please_keep_pin',
      desc: '',
      args: [],
    );
  }

  /// `The address book is empty`
  String get message_address_book_is_empty {
    return Intl.message(
      'The address book is empty',
      name: 'message_address_book_is_empty',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get action_send {
    return Intl.message('Send', name: 'action_send', desc: '', args: []);
  }

  /// `Too many errors, please use the pin code to unlock`
  String get fingerprint_too_many_errors_use_pin {
    return Intl.message(
      'Too many errors, please use the pin code to unlock',
      name: 'fingerprint_too_many_errors_use_pin',
      desc: '',
      args: [],
    );
  }

  /// `Trending`
  String get title_trending {
    return Intl.message('Trending', name: 'title_trending', desc: '', args: []);
  }

  /// `Popular`
  String get title_popular {
    return Intl.message('Popular', name: 'title_popular', desc: '', args: []);
  }

  /// `Copy address`
  String get copy_wallet_address {
    return Intl.message(
      'Copy address',
      name: 'copy_wallet_address',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Months`
  String get months {
    return Intl.message('Months', name: 'months', desc: '', args: []);
  }

  /// `Safe Account`
  String get title_safe_account {
    return Intl.message(
      'Safe Account',
      name: 'title_safe_account',
      desc: '',
      args: [],
    );
  }

  /// `No favorites`
  String get message_empty_dapp_favorite {
    return Intl.message(
      'No favorites',
      name: 'message_empty_dapp_favorite',
      desc: '',
      args: [],
    );
  }

  /// `My`
  String get my {
    return Intl.message('My', name: 'my', desc: '', args: []);
  }

  /// `Network fee`
  String get network_fee {
    return Intl.message('Network fee', name: 'network_fee', desc: '', args: []);
  }

  /// `Protect your wallet`
  String get title_protect_wallet {
    return Intl.message(
      'Protect your wallet',
      name: 'title_protect_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Cloud storage services`
  String get title_cloud_storage_services {
    return Intl.message(
      'Cloud storage services',
      name: 'title_cloud_storage_services',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get action_done {
    return Intl.message('Done', name: 'action_done', desc: '', args: []);
  }

  /// `Move`
  String get transaction_action_move {
    return Intl.message(
      'Move',
      name: 'transaction_action_move',
      desc: '',
      args: [],
    );
  }

  /// `MAX`
  String get action_max {
    return Intl.message('MAX', name: 'action_max', desc: '', args: []);
  }

  /// `empty`
  String get message_empty {
    return Intl.message('empty', name: 'message_empty', desc: '', args: []);
  }

  /// `Back up your wallet`
  String get title_backup_reminder {
    return Intl.message(
      'Back up your wallet',
      name: 'title_backup_reminder',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get transaction_action_sent {
    return Intl.message(
      'Send',
      name: 'transaction_action_sent',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get action_login {
    return Intl.message('Login', name: 'action_login', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Modify PIN code`
  String get modify_pin_code {
    return Intl.message(
      'Modify PIN code',
      name: 'modify_pin_code',
      desc: '',
      args: [],
    );
  }

  /// `From:`
  String get title_from_with_colon {
    return Intl.message(
      'From:',
      name: 'title_from_with_colon',
      desc: '',
      args: [],
    );
  }

  /// `Keep using seed phrase`
  String get keep_using_seed_phrase {
    return Intl.message(
      'Keep using seed phrase',
      name: 'keep_using_seed_phrase',
      desc: '',
      args: [],
    );
  }

  /// `Lock Time`
  String get title_staking_lock_time {
    return Intl.message(
      'Lock Time',
      name: 'title_staking_lock_time',
      desc: '',
      args: [],
    );
  }

  /// `Sell`
  String get action_sell {
    return Intl.message('Sell', name: 'action_sell', desc: '', args: []);
  }

  /// `Token Address`
  String get title_token_address {
    return Intl.message(
      'Token Address',
      name: 'title_token_address',
      desc: '',
      args: [],
    );
  }

  /// `Click to load more`
  String get message_click_load_more {
    return Intl.message(
      'Click to load more',
      name: 'message_click_load_more',
      desc: '',
      args: [],
    );
  }

  /// `Verification succeeded`
  String get message_verification_succeeded {
    return Intl.message(
      'Verification succeeded',
      name: 'message_verification_succeeded',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get title_address {
    return Intl.message('Address', name: 'title_address', desc: '', args: []);
  }

  /// `Categories`
  String get title_dapp_categories {
    return Intl.message(
      'Categories',
      name: 'title_dapp_categories',
      desc: '',
      args: [],
    );
  }

  /// `Connected`
  String get state_connected {
    return Intl.message(
      'Connected',
      name: 'state_connected',
      desc: '',
      args: [],
    );
  }

  /// `TX platform`
  String get flag_tx_platform {
    return Intl.message(
      'TX platform',
      name: 'flag_tx_platform',
      desc: '',
      args: [],
    );
  }

  /// `NFTs`
  String get title_nfts {
    return Intl.message('NFTs', name: 'title_nfts', desc: '', args: []);
  }

  /// `Terms of Service`
  String get title_terms_of_service {
    return Intl.message(
      'Terms of Service',
      name: 'title_terms_of_service',
      desc: '',
      args: [],
    );
  }

  /// `Delete the customized node`
  String get message_remove_customized_node {
    return Intl.message(
      'Delete the customized node',
      name: 'message_remove_customized_node',
      desc: '',
      args: [],
    );
  }

  /// `See All`
  String get action_see_all {
    return Intl.message('See All', name: 'action_see_all', desc: '', args: []);
  }

  /// `Sell`
  String get action_nft_sell {
    return Intl.message('Sell', name: 'action_nft_sell', desc: '', args: []);
  }

  /// `Clipboard emptied`
  String get message_clipboard_emptied {
    return Intl.message(
      'Clipboard emptied',
      name: 'message_clipboard_emptied',
      desc: '',
      args: [],
    );
  }

  /// `Backup to Cloud`
  String get message_format_add_cloud_backup {
    return Intl.message(
      'Backup to Cloud',
      name: 'message_format_add_cloud_backup',
      desc: '',
      args: [],
    );
  }

  /// `Still copy`
  String get action_still_copy {
    return Intl.message(
      'Still copy',
      name: 'action_still_copy',
      desc: '',
      args: [],
    );
  }

  /// `Contract Execution`
  String get title_contract_execution {
    return Intl.message(
      'Contract Execution',
      name: 'title_contract_execution',
      desc: '',
      args: [],
    );
  }

  /// `All Accounts`
  String get title_all_accounts {
    return Intl.message(
      'All Accounts',
      name: 'title_all_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Copy to clipboard`
  String get action_copy_to_clipboard {
    return Intl.message(
      'Copy to clipboard',
      name: 'action_copy_to_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Confirm phrase`
  String get action_confirm_phrase {
    return Intl.message(
      'Confirm phrase',
      name: 'action_confirm_phrase',
      desc: '',
      args: [],
    );
  }

  /// `Shared Account`
  String get title_shared_account {
    return Intl.message(
      'Shared Account',
      name: 'title_shared_account',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect mnemonic format`
  String get message_incorrect_mnemonic_format {
    return Intl.message(
      'Incorrect mnemonic format',
      name: 'message_incorrect_mnemonic_format',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect private key format`
  String get message_incorrect_private_key_format {
    return Intl.message(
      'Incorrect private key format',
      name: 'message_incorrect_private_key_format',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get flag_undelegate_amount {
    return Intl.message(
      'Amount',
      name: 'flag_undelegate_amount',
      desc: '',
      args: [],
    );
  }

  /// `Less`
  String get action_text_shrink {
    return Intl.message('Less', name: 'action_text_shrink', desc: '', args: []);
  }

  /// `Transfer`
  String get title_transfer {
    return Intl.message('Transfer', name: 'title_transfer', desc: '', args: []);
  }

  /// `Multi-Chain Wallet`
  String get title_multi_chain_wallet {
    return Intl.message(
      'Multi-Chain Wallet',
      name: 'title_multi_chain_wallet',
      desc: '',
      args: [],
    );
  }

  /// `No record`
  String get message_empty_dapp_history {
    return Intl.message(
      'No record',
      name: 'message_empty_dapp_history',
      desc: '',
      args: [],
    );
  }

  /// `No tokens found`
  String get message_no_coins_found {
    return Intl.message(
      'No tokens found',
      name: 'message_no_coins_found',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Receive`
  String get received {
    return Intl.message('Receive', name: 'received', desc: '', args: []);
  }

  /// `Enter the PIN again`
  String get Enter_PIN_again {
    return Intl.message(
      'Enter the PIN again',
      name: 'Enter_PIN_again',
      desc: '',
      args: [],
    );
  }

  /// `Fingerprint recognition is locked, please use pin code to unlock`
  String get fingerprint_recognition_is_locked_use_pin {
    return Intl.message(
      'Fingerprint recognition is locked, please use pin code to unlock',
      name: 'fingerprint_recognition_is_locked_use_pin',
      desc: '',
      args: [],
    );
  }

  /// `Payment account`
  String get payment_account {
    return Intl.message(
      'Payment account',
      name: 'payment_account',
      desc: '',
      args: [],
    );
  }

  /// `Fingerprint not recognized. Try again`
  String get fingerprint_not_recognized {
    return Intl.message(
      'Fingerprint not recognized. Try again',
      name: 'fingerprint_not_recognized',
      desc: '',
      args: [],
    );
  }

  /// `Current device does not support`
  String get not_support_fingerprint {
    return Intl.message(
      'Current device does not support',
      name: 'not_support_fingerprint',
      desc: '',
      args: [],
    );
  }

  /// `Total volume`
  String get flag_nft_total_volume {
    return Intl.message(
      'Total volume',
      name: 'flag_nft_total_volume',
      desc: '',
      args: [],
    );
  }

  /// `rewards:`
  String get flag_staking_rewards_with_colon {
    return Intl.message(
      'rewards:',
      name: 'flag_staking_rewards_with_colon',
      desc: '',
      args: [],
    );
  }

  /// `your e-mail`
  String get hint_your_email {
    return Intl.message(
      'your e-mail',
      name: 'hint_your_email',
      desc: '',
      args: [],
    );
  }

  /// `Choose Account`
  String get title_choose_account {
    return Intl.message(
      'Choose Account',
      name: 'title_choose_account',
      desc: '',
      args: [],
    );
  }

  /// `Receive`
  String get transaction_action_received {
    return Intl.message(
      'Receive',
      name: 'transaction_action_received',
      desc: '',
      args: [],
    );
  }

  /// `New Wallet`
  String get action_new_wallet {
    return Intl.message(
      'New Wallet',
      name: 'action_new_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Top`
  String get title_top {
    return Intl.message('Top', name: 'title_top', desc: '', args: []);
  }

  /// `Failure`
  String get transaction_action_failure {
    return Intl.message(
      'Failure',
      name: 'transaction_action_failure',
      desc: '',
      args: [],
    );
  }

  /// `Initializing your wallet`
  String get message_initializing_your_wallet {
    return Intl.message(
      'Initializing your wallet',
      name: 'message_initializing_your_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Coin`
  String get title_coin {
    return Intl.message('Coin', name: 'title_coin', desc: '', args: []);
  }

  /// `Choose network`
  String get title_choose_network {
    return Intl.message(
      'Choose network',
      name: 'title_choose_network',
      desc: '',
      args: [],
    );
  }

  /// `cannot be empty`
  String get form_is_not_empty {
    return Intl.message(
      'cannot be empty',
      name: 'form_is_not_empty',
      desc: '',
      args: [],
    );
  }

  /// `Verification failed`
  String get message_verification_failed {
    return Intl.message(
      'Verification failed',
      name: 'message_verification_failed',
      desc: '',
      args: [],
    );
  }

  /// `Add custom token`
  String get title_add_custom_token {
    return Intl.message(
      'Add custom token',
      name: 'title_add_custom_token',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message('Refresh', name: 'refresh', desc: '', args: []);
  }

  /// `Backup to GoogleDrive`
  String get message_format_add_cloud_backup_google_drive {
    return Intl.message(
      'Backup to GoogleDrive',
      name: 'message_format_add_cloud_backup_google_drive',
      desc: '',
      args: [],
    );
  }

  /// `Email is bound`
  String get message_email_bound {
    return Intl.message(
      'Email is bound',
      name: 'message_email_bound',
      desc: '',
      args: [],
    );
  }

  /// `Buy NFT`
  String get title_nft_buy {
    return Intl.message('Buy NFT', name: 'title_nft_buy', desc: '', args: []);
  }

  /// `Stake`
  String get title_staking_stake {
    return Intl.message(
      'Stake',
      name: 'title_staking_stake',
      desc: '',
      args: [],
    );
  }

  /// `Set as a general address, applicable to all currencies under the network`
  String get message_set_as_general_address {
    return Intl.message(
      'Set as a general address, applicable to all currencies under the network',
      name: 'message_set_as_general_address',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help_center {
    return Intl.message('Help', name: 'help_center', desc: '', args: []);
  }

  /// `Copy link`
  String get copy_url_web {
    return Intl.message('Copy link', name: 'copy_url_web', desc: '', args: []);
  }

  /// `Custom token`
  String get action_custom_token {
    return Intl.message(
      'Custom token',
      name: 'action_custom_token',
      desc: '',
      args: [],
    );
  }

  /// `Please keep at least one cloud backup for the security wallet`
  String get message_safe_wallet_remove_cloud_backup {
    return Intl.message(
      'Please keep at least one cloud backup for the security wallet',
      name: 'message_safe_wallet_remove_cloud_backup',
      desc: '',
      args: [],
    );
  }

  /// `For your team or family`
  String get message_introduce_shared_account {
    return Intl.message(
      'For your team or family',
      name: 'message_introduce_shared_account',
      desc: '',
      args: [],
    );
  }

  /// `Enter a new PIN`
  String get Enter_new_PIN {
    return Intl.message(
      'Enter a new PIN',
      name: 'Enter_new_PIN',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient balance`
  String get message_insufficient_balance {
    return Intl.message(
      'Insufficient balance',
      name: 'message_insufficient_balance',
      desc: '',
      args: [],
    );
  }

  /// `New connection`
  String get action_new_connection {
    return Intl.message(
      'New connection',
      name: 'action_new_connection',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this wallet? After deletion, you can re-import the wallet through the backed up Recovery phrase.`
  String get delete_wallet_dialog_content {
    return Intl.message(
      'Are you sure you want to delete this wallet? After deletion, you can re-import the wallet through the backed up Recovery phrase.',
      name: 'delete_wallet_dialog_content',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get action_disconnect {
    return Intl.message(
      'Disconnect',
      name: 'action_disconnect',
      desc: '',
      args: [],
    );
  }

  /// `Token name`
  String get hint_search_coins {
    return Intl.message(
      'Token name',
      name: 'hint_search_coins',
      desc: '',
      args: [],
    );
  }

  /// `No transfer activity`
  String get message_no_transfer_activity {
    return Intl.message(
      'No transfer activity',
      name: 'message_no_transfer_activity',
      desc: '',
      args: [],
    );
  }

  /// `Delete OneDrive backup`
  String get message_format_remove_cloud_backup_onedrive {
    return Intl.message(
      'Delete OneDrive backup',
      name: 'message_format_remove_cloud_backup_onedrive',
      desc: '',
      args: [],
    );
  }

  /// `Token Standard`
  String get flag_token_standard {
    return Intl.message(
      'Token Standard',
      name: 'flag_token_standard',
      desc: '',
      args: [],
    );
  }

  /// `Switch node`
  String get title_switch_node {
    return Intl.message(
      'Switch node',
      name: 'title_switch_node',
      desc: '',
      args: [],
    );
  }

  /// `PIN Code login`
  String get pin_code_login {
    return Intl.message(
      'PIN Code login',
      name: 'pin_code_login',
      desc: '',
      args: [],
    );
  }

  /// `Address: `
  String get caption_address_with_colon {
    return Intl.message(
      'Address: ',
      name: 'caption_address_with_colon',
      desc: '',
      args: [],
    );
  }

  /// `Uses multi-signature to co-sign`
  String get message_introduce_safe_account {
    return Intl.message(
      'Uses multi-signature to co-sign',
      name: 'message_introduce_safe_account',
      desc: '',
      args: [],
    );
  }

  /// `Buy`
  String get action_buy {
    return Intl.message('Buy', name: 'action_buy', desc: '', args: []);
  }

  /// `No available account found`
  String get message_no_available_account_found {
    return Intl.message(
      'No available account found',
      name: 'message_no_available_account_found',
      desc: '',
      args: [],
    );
  }

  /// `Token has expired`
  String get message_token_has_expired {
    return Intl.message(
      'Token has expired',
      name: 'message_token_has_expired',
      desc: '',
      args: [],
    );
  }

  /// `Staking`
  String get title_staking {
    return Intl.message('Staking', name: 'title_staking', desc: '', args: []);
  }

  /// `Tap to Switch`
  String get message_tap_to_switch {
    return Intl.message(
      'Tap to Switch',
      name: 'message_tap_to_switch',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out of your cloud storage service account?`
  String get message_disconnect_from_cloud {
    return Intl.message(
      'Are you sure you want to log out of your cloud storage service account?',
      name: 'message_disconnect_from_cloud',
      desc: '',
      args: [],
    );
  }

  /// `auto lock`
  String get title_auto_lock {
    return Intl.message(
      'auto lock',
      name: 'title_auto_lock',
      desc: '',
      args: [],
    );
  }

  /// `Please set the PIN lock first`
  String get please_set_pin_first {
    return Intl.message(
      'Please set the PIN lock first',
      name: 'please_set_pin_first',
      desc: '',
      args: [],
    );
  }

  /// `Items`
  String get flag_nft_items {
    return Intl.message('Items', name: 'flag_nft_items', desc: '', args: []);
  }

  /// `Copy Recovery Phrase`
  String get title_copy_secret_recovery_phrase {
    return Intl.message(
      'Copy Recovery Phrase',
      name: 'title_copy_secret_recovery_phrase',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get action_restore {
    return Intl.message('Restore', name: 'action_restore', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Nodes`
  String get title_dapp_node_settings {
    return Intl.message(
      'Nodes',
      name: 'title_dapp_node_settings',
      desc: '',
      args: [],
    );
  }

  /// `Too many errors, please try again later`
  String get fingerprint_too_many_errors_Later {
    return Intl.message(
      'Too many errors, please try again later',
      name: 'fingerprint_too_many_errors_Later',
      desc: '',
      args: [],
    );
  }

  /// `Link copied`
  String get message_link_copied {
    return Intl.message(
      'Link copied',
      name: 'message_link_copied',
      desc: '',
      args: [],
    );
  }

  /// `Delete cloud backup`
  String get message_format_remove_cloud_backup {
    return Intl.message(
      'Delete cloud backup',
      name: 'message_format_remove_cloud_backup',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get subtitle_all {
    return Intl.message('All', name: 'subtitle_all', desc: '', args: []);
  }

  /// `Confirm to buy`
  String get title_confirm_buy {
    return Intl.message(
      'Confirm to buy',
      name: 'title_confirm_buy',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get title_rpc_node {
    return Intl.message('Note', name: 'title_rpc_node', desc: '', args: []);
  }

  /// `Requester`
  String get title_requester {
    return Intl.message(
      'Requester',
      name: 'title_requester',
      desc: '',
      args: [],
    );
  }

  /// `Hours`
  String get hours {
    return Intl.message('Hours', name: 'hours', desc: '', args: []);
  }

  /// `Continue`
  String get action_continue {
    return Intl.message(
      'Continue',
      name: 'action_continue',
      desc: '',
      args: [],
    );
  }

  /// `Properties`
  String get title_properties {
    return Intl.message(
      'Properties',
      name: 'title_properties',
      desc: '',
      args: [],
    );
  }

  /// `Tap to show recovery phrase`
  String get action_tap_to_show_mnemonic {
    return Intl.message(
      'Tap to show recovery phrase',
      name: 'action_tap_to_show_mnemonic',
      desc: '',
      args: [],
    );
  }

  /// `Tap to show private key`
  String get action_tap_to_show_private_key {
    return Intl.message(
      'Tap to show private key',
      name: 'action_tap_to_show_private_key',
      desc: '',
      args: [],
    );
  }

  /// `The current node is unavailable, please try to switch the node`
  String get message_node_is_unavailable {
    return Intl.message(
      'The current node is unavailable, please try to switch the node',
      name: 'message_node_is_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Bind email`
  String get title_bind_email {
    return Intl.message(
      'Bind email',
      name: 'title_bind_email',
      desc: '',
      args: [],
    );
  }

  /// `In progress`
  String get business_status_pending {
    return Intl.message(
      'In progress',
      name: 'business_status_pending',
      desc: '',
      args: [],
    );
  }

  /// `Do you need to save the address where you just made the transaction?`
  String get title_address_book_add_need_to_save {
    return Intl.message(
      'Do you need to save the address where you just made the transaction?',
      name: 'title_address_book_add_need_to_save',
      desc: '',
      args: [],
    );
  }

  /// `Choose network and account`
  String get title_choose_network_and_account {
    return Intl.message(
      'Choose network and account',
      name: 'title_choose_network_and_account',
      desc: '',
      args: [],
    );
  }

  /// `Add Account`
  String get title_add_account {
    return Intl.message(
      'Add Account',
      name: 'title_add_account',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exit_app {
    return Intl.message('Exit', name: 'exit_app', desc: '', args: []);
  }

  /// `Available`
  String get title_staking_available {
    return Intl.message(
      'Available',
      name: 'title_staking_available',
      desc: '',
      args: [],
    );
  }

  /// `Label(optional)`
  String get title_label_optional {
    return Intl.message(
      'Label(optional)',
      name: 'title_label_optional',
      desc: '',
      args: [],
    );
  }

  /// `Add custom node`
  String get title_add_custom_node {
    return Intl.message(
      'Add custom node',
      name: 'title_add_custom_node',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get transaction_status_canceled {
    return Intl.message(
      'Canceled',
      name: 'transaction_status_canceled',
      desc: '',
      args: [],
    );
  }

  /// `Dropped`
  String get transaction_status_dropped {
    return Intl.message(
      'Dropped',
      name: 'transaction_status_dropped',
      desc: '',
      args: [],
    );
  }

  /// `Mail Verification Code`
  String get hint_mail_code {
    return Intl.message(
      'Mail Verification Code',
      name: 'hint_mail_code',
      desc: '',
      args: [],
    );
  }

  /// `Activating`
  String get status_activating {
    return Intl.message(
      'Activating',
      name: 'status_activating',
      desc: '',
      args: [],
    );
  }

  /// `The responsibility for keeping the recovery phrase safe lies entirely with me.`
  String get message_mnemonic_show_warn_check3 {
    return Intl.message(
      'The responsibility for keeping the recovery phrase safe lies entirely with me.',
      name: 'message_mnemonic_show_warn_check3',
      desc: '',
      args: [],
    );
  }

  /// `If I disclose or share my recovery phrase with anyone, my assets could be stolen.`
  String get message_mnemonic_show_warn_check2 {
    return Intl.message(
      'If I disclose or share my recovery phrase with anyone, my assets could be stolen.',
      name: 'message_mnemonic_show_warn_check2',
      desc: '',
      args: [],
    );
  }

  /// `If I lose my recovery phrase, my assets will be lost forever.`
  String get message_mnemonic_show_warn_check1 {
    return Intl.message(
      'If I lose my recovery phrase, my assets will be lost forever.',
      name: 'message_mnemonic_show_warn_check1',
      desc: '',
      args: [],
    );
  }

  /// `Do not disclose your private key to anyone, including individuals, websites, or applications.`
  String get message_private_key_show_warn_check1 {
    return Intl.message(
      'Do not disclose your private key to anyone, including individuals, websites, or applications.',
      name: 'message_private_key_show_warn_check1',
      desc: '',
      args: [],
    );
  }

  /// `If someone gets my private key, my assets could be stolen, and there is no way to recover the lost funds.`
  String get message_private_key_show_warn_check2 {
    return Intl.message(
      'If someone gets my private key, my assets could be stolen, and there is no way to recover the lost funds.',
      name: 'message_private_key_show_warn_check2',
      desc: '',
      args: [],
    );
  }

  /// `The responsibility for keeping the private key safe lies entirely with me.`
  String get message_private_key_show_warn_check3 {
    return Intl.message(
      'The responsibility for keeping the private key safe lies entirely with me.',
      name: 'message_private_key_show_warn_check3',
      desc: '',
      args: [],
    );
  }

  /// `This will reload the page.`
  String get message_will_reload_the_page {
    return Intl.message(
      'This will reload the page.',
      name: 'message_will_reload_the_page',
      desc: '',
      args: [],
    );
  }

  /// `Signed transaction`
  String get subtitle_signed_transaction {
    return Intl.message(
      'Signed transaction',
      name: 'subtitle_signed_transaction',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get action_accept {
    return Intl.message('Accept', name: 'action_accept', desc: '', args: []);
  }

  /// `No NFT found`
  String get message_nft_empty {
    return Intl.message(
      'No NFT found',
      name: 'message_nft_empty',
      desc: '',
      args: [],
    );
  }

  /// `Restore with recovery phrase`
  String get title_restore_with_mnemonic {
    return Intl.message(
      'Restore with recovery phrase',
      name: 'title_restore_with_mnemonic',
      desc: '',
      args: [],
    );
  }

  /// `Ready`
  String get transaction_status_ready {
    return Intl.message(
      'Ready',
      name: 'transaction_status_ready',
      desc: '',
      args: [],
    );
  }

  /// `Scan to join`
  String get message_scan_to_join {
    return Intl.message(
      'Scan to join',
      name: 'message_scan_to_join',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get action_confirm {
    return Intl.message('Confirm', name: 'action_confirm', desc: '', args: []);
  }

  /// `All read`
  String get read_all {
    return Intl.message('All read', name: 'read_all', desc: '', args: []);
  }

  /// `Your wallet is backed up`
  String get message_wallet_backed_up {
    return Intl.message(
      'Your wallet is backed up',
      name: 'message_wallet_backed_up',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get hint_email {
    return Intl.message('Email', name: 'hint_email', desc: '', args: []);
  }

  /// `Status`
  String get title_status {
    return Intl.message('Status', name: 'title_status', desc: '', args: []);
  }

  /// `Manage tokens`
  String get title_manage_favorite_coins {
    return Intl.message(
      'Manage tokens',
      name: 'title_manage_favorite_coins',
      desc: '',
      args: [],
    );
  }

  /// `To save`
  String get action_to_save {
    return Intl.message('To save', name: 'action_to_save', desc: '', args: []);
  }

  /// `Start`
  String get action_start {
    return Intl.message('Start', name: 'action_start', desc: '', args: []);
  }

  /// `Make sure no one is looking at your screen`
  String get message_make_sure_no_one_look_your_sreen {
    return Intl.message(
      'Make sure no one is looking at your screen',
      name: 'message_make_sure_no_one_look_your_sreen',
      desc: '',
      args: [],
    );
  }

  /// `Add address`
  String get title_add_address {
    return Intl.message(
      'Add address',
      name: 'title_add_address',
      desc: '',
      args: [],
    );
  }

  /// `Transfer`
  String get action_transfer {
    return Intl.message(
      'Transfer',
      name: 'action_transfer',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Input Mnemonic`
  String get edit_import_wallet_mnemonics_hint {
    return Intl.message(
      'Input Mnemonic',
      name: 'edit_import_wallet_mnemonics_hint',
      desc: '',
      args: [],
    );
  }

  /// `Touch sensor`
  String get fingerprint_hint {
    return Intl.message(
      'Touch sensor',
      name: 'fingerprint_hint',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get action_ok {
    return Intl.message('OK', name: 'action_ok', desc: '', args: []);
  }

  /// `Founder`
  String get message_founder {
    return Intl.message('Founder', name: 'message_founder', desc: '', args: []);
  }

  /// `Select wallet`
  String get choose_wallet {
    return Intl.message(
      'Select wallet',
      name: 'choose_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Activate account`
  String get title_activate_account {
    return Intl.message(
      'Activate account',
      name: 'title_activate_account',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get action_sign_out {
    return Intl.message(
      'Sign out',
      name: 'action_sign_out',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get wallet {
    return Intl.message('Wallet', name: 'wallet', desc: '', args: []);
  }

  /// `Fingerprint recognized`
  String get fingerprint_success {
    return Intl.message(
      'Fingerprint recognized',
      name: 'fingerprint_success',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `Creating your wallet`
  String get message_creating_your_wallet {
    return Intl.message(
      'Creating your wallet',
      name: 'message_creating_your_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Backup to cloud storage services`
  String get title_backup_to_cloud_storage_services {
    return Intl.message(
      'Backup to cloud storage services',
      name: 'title_backup_to_cloud_storage_services',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get title_date {
    return Intl.message('Date', name: 'title_date', desc: '', args: []);
  }

  /// `Scan QR code`
  String get title_scan_qr {
    return Intl.message(
      'Scan QR code',
      name: 'title_scan_qr',
      desc: '',
      args: [],
    );
  }

  /// `Activated`
  String get status_activated {
    return Intl.message(
      'Activated',
      name: 'status_activated',
      desc: '',
      args: [],
    );
  }

  /// `Inactivated`
  String get status_inactivated {
    return Intl.message(
      'Inactivated',
      name: 'status_inactivated',
      desc: '',
      args: [],
    );
  }

  /// `insufficient liquidity for this trade`
  String get message_trade_insufficient_liquidity {
    return Intl.message(
      'insufficient liquidity for this trade',
      name: 'message_trade_insufficient_liquidity',
      desc: '',
      args: [],
    );
  }

  /// `Custodial Account`
  String get title_custodial_account {
    return Intl.message(
      'Custodial Account',
      name: 'title_custodial_account',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get title_from {
    return Intl.message('From', name: 'title_from', desc: '', args: []);
  }

  /// `Check failed`
  String get message_cloud_backup_check_failed {
    return Intl.message(
      'Check failed',
      name: 'message_cloud_backup_check_failed',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get action_create {
    return Intl.message('Create', name: 'action_create', desc: '', args: []);
  }

  /// `staked:`
  String get flag_staking_staked_with_colon {
    return Intl.message(
      'staked:',
      name: 'flag_staking_staked_with_colon',
      desc: '',
      args: [],
    );
  }

  /// `Signature info`
  String get title_signature_info {
    return Intl.message(
      'Signature info',
      name: 'title_signature_info',
      desc: '',
      args: [],
    );
  }

  /// `Total assets`
  String get total_assets {
    return Intl.message(
      'Total assets',
      name: 'total_assets',
      desc: '',
      args: [],
    );
  }

  /// `Mnemonic has been imported`
  String get message_mnemonic_been_imported {
    return Intl.message(
      'Mnemonic has been imported',
      name: 'message_mnemonic_been_imported',
      desc: '',
      args: [],
    );
  }

  /// `Enter the label for the address`
  String get hint_input_address_label {
    return Intl.message(
      'Enter the label for the address',
      name: 'hint_input_address_label',
      desc: '',
      args: [],
    );
  }

  /// `Direction`
  String get title_direction {
    return Intl.message(
      'Direction',
      name: 'title_direction',
      desc: '',
      args: [],
    );
  }

  /// `Receive`
  String get action_receive {
    return Intl.message('Receive', name: 'action_receive', desc: '', args: []);
  }

  /// `Deposit`
  String get action_deposit {
    return Intl.message('Deposit', name: 'action_deposit', desc: '', args: []);
  }

  /// `Not recognized`
  String get message_not_recognized {
    return Intl.message(
      'Not recognized',
      name: 'message_not_recognized',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get action_skip {
    return Intl.message('Skip', name: 'action_skip', desc: '', args: []);
  }

  /// `Sign the transaction`
  String get title_sign_the_transaction {
    return Intl.message(
      'Sign the transaction',
      name: 'title_sign_the_transaction',
      desc: '',
      args: [],
    );
  }

  /// `Select Coin and Network`
  String get title_select_coin_network {
    return Intl.message(
      'Select Coin and Network',
      name: 'title_select_coin_network',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get transaction_status_failed {
    return Intl.message(
      'Failed',
      name: 'transaction_status_failed',
      desc: '',
      args: [],
    );
  }

  /// `Address Book`
  String get title_address_book {
    return Intl.message(
      'Address Book',
      name: 'title_address_book',
      desc: '',
      args: [],
    );
  }

  /// `Confirm fingerprint to continue`
  String get fingerprint_description {
    return Intl.message(
      'Confirm fingerprint to continue',
      name: 'fingerprint_description',
      desc: '',
      args: [],
    );
  }

  /// `Balance Changes`
  String get flag_balance_change {
    return Intl.message(
      'Balance Changes',
      name: 'flag_balance_change',
      desc: '',
      args: [],
    );
  }

  /// `Swap`
  String get action_swap {
    return Intl.message('Swap', name: 'action_swap', desc: '', args: []);
  }

  /// `To address`
  String get title_to_address {
    return Intl.message(
      'To address',
      name: 'title_to_address',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get from_address {
    return Intl.message('From', name: 'from_address', desc: '', args: []);
  }

  /// `The same address already exists`
  String get message_same_address_already_exists {
    return Intl.message(
      'The same address already exists',
      name: 'message_same_address_already_exists',
      desc: '',
      args: [],
    );
  }

  /// `Gas Price`
  String get gas_price {
    return Intl.message('Gas Price', name: 'gas_price', desc: '', args: []);
  }

  /// `More`
  String get action_text_expend {
    return Intl.message('More', name: 'action_text_expend', desc: '', args: []);
  }

  /// `Owner`
  String get flag_owner {
    return Intl.message('Owner', name: 'flag_owner', desc: '', args: []);
  }

  /// `The transaction has expired due to waiting too long and has been resume for you.`
  String get message_trade_resume_transaction {
    return Intl.message(
      'The transaction has expired due to waiting too long and has been resume for you.',
      name: 'message_trade_resume_transaction',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get sent {
    return Intl.message('Send', name: 'sent', desc: '', args: []);
  }

  /// `View your account balance and activity`
  String get message_wc_session_review_text1 {
    return Intl.message(
      'View your account balance and activity',
      name: 'message_wc_session_review_text1',
      desc: '',
      args: [],
    );
  }

  /// `Request approval of transaction`
  String get message_wc_session_review_text2 {
    return Intl.message(
      'Request approval of transaction',
      name: 'message_wc_session_review_text2',
      desc: '',
      args: [],
    );
  }

  /// `Fingerprint login`
  String get fingerprint_login {
    return Intl.message(
      'Fingerprint login',
      name: 'fingerprint_login',
      desc: '',
      args: [],
    );
  }

  /// `Sending Account`
  String get title_sending_holder {
    return Intl.message(
      'Sending Account',
      name: 'title_sending_holder',
      desc: '',
      args: [],
    );
  }

  /// `Choose photo`
  String get title_choose_photo {
    return Intl.message(
      'Choose photo',
      name: 'title_choose_photo',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get transfer_amount {
    return Intl.message('Amount', name: 'transfer_amount', desc: '', args: []);
  }

  /// `Create PIN`
  String get action_create_pin {
    return Intl.message(
      'Create PIN',
      name: 'action_create_pin',
      desc: '',
      args: [],
    );
  }

  /// `The pasteboard of your phone will cache what you copy, and other apps can get your recovery phrase from it! Are you sure you want to copy the recovery phrase to the pasteboard?`
  String get message_warn_secret_recovery_phrase {
    return Intl.message(
      'The pasteboard of your phone will cache what you copy, and other apps can get your recovery phrase from it! Are you sure you want to copy the recovery phrase to the pasteboard?',
      name: 'message_warn_secret_recovery_phrase',
      desc: '',
      args: [],
    );
  }

  /// `Enter or paste token address`
  String get hint_enter_paste_token_address {
    return Intl.message(
      'Enter or paste token address',
      name: 'hint_enter_paste_token_address',
      desc: '',
      args: [],
    );
  }

  /// `Delete GoogleDrive  backup`
  String get message_format_remove_cloud_backup_google_drive {
    return Intl.message(
      'Delete GoogleDrive  backup',
      name: 'message_format_remove_cloud_backup_google_drive',
      desc: '',
      args: [],
    );
  }

  /// `App lock`
  String get title_app_lock {
    return Intl.message('App lock', name: 'title_app_lock', desc: '', args: []);
  }

  /// `The PIN code is incorrect, please enter again`
  String get pin_incorret_again {
    return Intl.message(
      'The PIN code is incorrect, please enter again',
      name: 'pin_incorret_again',
      desc: '',
      args: [],
    );
  }

  /// `Checking…`
  String get message_cloud_backup_checking {
    return Intl.message(
      'Checking…',
      name: 'message_cloud_backup_checking',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get action_close {
    return Intl.message('Close', name: 'action_close', desc: '', args: []);
  }

  /// `Scan`
  String get scan_it {
    return Intl.message('Scan', name: 'scan_it', desc: '', args: []);
  }

  /// `Floor`
  String get flag_floor_price {
    return Intl.message('Floor', name: 'flag_floor_price', desc: '', args: []);
  }

  /// `Rejected`
  String get transaction_status_rejected {
    return Intl.message(
      'Rejected',
      name: 'transaction_status_rejected',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get action_exit {
    return Intl.message('Exit', name: 'action_exit', desc: '', args: []);
  }

  /// `If you lose this device, you can restore your wallet with the recovery phrase you saved.`
  String get message_wallet_manually_backed_up_detailed {
    return Intl.message(
      'If you lose this device, you can restore your wallet with the recovery phrase you saved.',
      name: 'message_wallet_manually_backed_up_detailed',
      desc: '',
      args: [],
    );
  }

  /// `Saved`
  String get message_saved {
    return Intl.message('Saved', name: 'message_saved', desc: '', args: []);
  }

  /// `Custom node`
  String get title_custom_node {
    return Intl.message(
      'Custom node',
      name: 'title_custom_node',
      desc: '',
      args: [],
    );
  }

  /// `Fingerprint recognition is locked, please try again later`
  String get fingerprint_recognition_is_locked_Later {
    return Intl.message(
      'Fingerprint recognition is locked, please try again later',
      name: 'fingerprint_recognition_is_locked_Later',
      desc: '',
      args: [],
    );
  }

  /// `Shared account created`
  String get message_shard_account_invitation_note_finish {
    return Intl.message(
      'Shared account created',
      name: 'message_shard_account_invitation_note_finish',
      desc: '',
      args: [],
    );
  }

  /// `To address`
  String get receipt_address {
    return Intl.message(
      'To address',
      name: 'receipt_address',
      desc: '',
      args: [],
    );
  }

  /// `Get started`
  String get action_get_started {
    return Intl.message(
      'Get started',
      name: 'action_get_started',
      desc: '',
      args: [],
    );
  }

  /// `Nodes`
  String get title_node_settings {
    return Intl.message(
      'Nodes',
      name: 'title_node_settings',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get flag_source {
    return Intl.message('Source', name: 'flag_source', desc: '', args: []);
  }

  /// `Amount`
  String get flag_transfer_amount {
    return Intl.message(
      'Amount',
      name: 'flag_transfer_amount',
      desc: '',
      args: [],
    );
  }

  /// `External Account`
  String get title_external_account {
    return Intl.message(
      'External Account',
      name: 'title_external_account',
      desc: '',
      args: [],
    );
  }

  /// `Join`
  String get action_join {
    return Intl.message('Join', name: 'action_join', desc: '', args: []);
  }

  /// `Transaction Data (optional)`
  String get rebuild_transaction_data_optional {
    return Intl.message(
      'Transaction Data (optional)',
      name: 'rebuild_transaction_data_optional',
      desc: '',
      args: [],
    );
  }

  /// `Floor price`
  String get flag_nft_floor_price {
    return Intl.message(
      'Floor price',
      name: 'flag_nft_floor_price',
      desc: '',
      args: [],
    );
  }

  /// `Request authentication`
  String get title_request_authentication {
    return Intl.message(
      'Request authentication',
      name: 'title_request_authentication',
      desc: '',
      args: [],
    );
  }

  /// `Not set`
  String get message_not_set {
    return Intl.message('Not set', name: 'message_not_set', desc: '', args: []);
  }

  /// `Created successfully`
  String get created_successfully {
    return Intl.message(
      'Created successfully',
      name: 'created_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Saved to {arg1}`
  String receipt_picture_saved_to(Object arg1) {
    return Intl.message(
      'Saved to $arg1',
      name: 'receipt_picture_saved_to',
      desc: '',
      args: [arg1],
    );
  }

  /// `Collection {arg1}`
  String caption_receipt_coin_network(Object arg1) {
    return Intl.message(
      'Collection $arg1',
      name: 'caption_receipt_coin_network',
      desc: '',
      args: [arg1],
    );
  }

  /// `Quantity: {arg1}`
  String format_flag_quantity_with_colon(Object arg1) {
    return Intl.message(
      'Quantity: $arg1',
      name: 'format_flag_quantity_with_colon',
      desc: '',
      args: [arg1],
    );
  }

  /// `{arg1} want to connect your wallet`
  String format_dapp_want_connect_wallet(Object arg1) {
    return Intl.message(
      '$arg1 want to connect your wallet',
      name: 'format_dapp_want_connect_wallet',
      desc: '',
      args: [arg1],
    );
  }

  /// `Unstake {arg1}`
  String format_title_staking_undelegate(Object arg1) {
    return Intl.message(
      'Unstake $arg1',
      name: 'format_title_staking_undelegate',
      desc: '',
      args: [arg1],
    );
  }

  /// `Receive {arg1}`
  String format_title_receipt(Object arg1) {
    return Intl.message(
      'Receive $arg1',
      name: 'format_title_receipt',
      desc: '',
      args: [arg1],
    );
  }

  /// `Send {arg1}`
  String format_title_transfer(Object arg1) {
    return Intl.message(
      'Send $arg1',
      name: 'format_title_transfer',
      desc: '',
      args: [arg1],
    );
  }

  /// `Balance Change {arg1}`
  String format_balance_change_flag(Object arg1) {
    return Intl.message(
      'Balance Change $arg1',
      name: 'format_balance_change_flag',
      desc: '',
      args: [arg1],
    );
  }

  /// `Backup under {arg1}`
  String message_format_cloud_backup_account(Object arg1) {
    return Intl.message(
      'Backup under $arg1',
      name: 'message_format_cloud_backup_account',
      desc: '',
      args: [arg1],
    );
  }

  /// `Saved to {arg1}`
  String transaction_details_picture_saved_to(Object arg1) {
    return Intl.message(
      'Saved to $arg1',
      name: 'transaction_details_picture_saved_to',
      desc: '',
      args: [arg1],
    );
  }

  /// `Scan results are not provided by {arg1}, please use with caution`
  String format_message_scanner_result_statement(Object arg1) {
    return Intl.message(
      'Scan results are not provided by $arg1, please use with caution',
      name: 'format_message_scanner_result_statement',
      desc: '',
      args: [arg1],
    );
  }

  /// `Network: {arg1}`
  String format_network_with_colon(Object arg1) {
    return Intl.message(
      'Network: $arg1',
      name: 'format_network_with_colon',
      desc: '',
      args: [arg1],
    );
  }

  /// `Stake {arg1}`
  String format_title_staking_delegate(Object arg1) {
    return Intl.message(
      'Stake $arg1',
      name: 'format_title_staking_delegate',
      desc: '',
      args: [arg1],
    );
  }

  /// `Network fee: {arg1}`
  String network_fee_format(Object arg1) {
    return Intl.message(
      'Network fee: $arg1',
      name: 'network_fee_format',
      desc: '',
      args: [arg1],
    );
  }

  /// `This address only supports {arg1} assets, please do not transfer to other public chain assets.`
  String format_receipt_note(Object arg1) {
    return Intl.message(
      'This address only supports $arg1 assets, please do not transfer to other public chain assets.',
      name: 'format_receipt_note',
      desc: '',
      args: [arg1],
    );
  }

  /// `Since the {arg1} transaction fee is not fixed, the {arg1} will charge part of the fee according to the blockchain network demand`
  String message_activate_safe_account(Object arg1) {
    return Intl.message(
      'Since the $arg1 transaction fee is not fixed, the $arg1 will charge part of the fee according to the blockchain network demand',
      name: 'message_activate_safe_account',
      desc: '',
      args: [arg1],
    );
  }

  /// `Version {arg1}`
  String format_version(Object arg1) {
    return Intl.message(
      'Version $arg1',
      name: 'format_version',
      desc: '',
      args: [arg1],
    );
  }

  /// `Connect`
  String get action_connect {
    return Intl.message('Connect', name: 'action_connect', desc: '', args: []);
  }

  /// `Add wallet`
  String get action_add_wallet {
    return Intl.message(
      'Add wallet',
      name: 'action_add_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Contacts`
  String get title_contacts {
    return Intl.message('Contacts', name: 'title_contacts', desc: '', args: []);
  }

  /// `New Contact`
  String get title_new_contact {
    return Intl.message(
      'New Contact',
      name: 'title_new_contact',
      desc: '',
      args: [],
    );
  }

  /// `Add address`
  String get action_add_address {
    return Intl.message(
      'Add address',
      name: 'action_add_address',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get label_contact_name {
    return Intl.message('Name', name: 'label_contact_name', desc: '', args: []);
  }

  /// `Discover`
  String get title_discover {
    return Intl.message('Discover', name: 'title_discover', desc: '', args: []);
  }

  /// `Delete contact`
  String get action_delete_contact {
    return Intl.message(
      'Delete contact',
      name: 'action_delete_contact',
      desc: '',
      args: [],
    );
  }

  /// `Transactions`
  String get title_transaction_record {
    return Intl.message(
      'Transactions',
      name: 'title_transaction_record',
      desc: '',
      args: [],
    );
  }

  /// `More transactions`
  String get title_more_transactions {
    return Intl.message(
      'More transactions',
      name: 'title_more_transactions',
      desc: '',
      args: [],
    );
  }

  /// `View on Explorer`
  String get action_view_on_explorer {
    return Intl.message(
      'View on Explorer',
      name: 'action_view_on_explorer',
      desc: '',
      args: [],
    );
  }

  /// `View {arg1}`
  String action_view_feed_address(Object arg1) {
    return Intl.message(
      'View $arg1',
      name: 'action_view_feed_address',
      desc: '',
      args: [arg1],
    );
  }

  /// `now`
  String get date_format_now {
    return Intl.message('now', name: 'date_format_now', desc: '', args: []);
  }

  /// `{arg1}m`
  String date_format_minute_ago(Object arg1) {
    return Intl.message(
      '${arg1}m',
      name: 'date_format_minute_ago',
      desc: '',
      args: [arg1],
    );
  }

  /// `{arg1}h`
  String date_format_hour_ago(Object arg1) {
    return Intl.message(
      '${arg1}h',
      name: 'date_format_hour_ago',
      desc: '',
      args: [arg1],
    );
  }

  /// `{arg1}d`
  String date_format_day_ago(Object arg1) {
    return Intl.message(
      '${arg1}d',
      name: 'date_format_day_ago',
      desc: '',
      args: [arg1],
    );
  }

  /// `{arg1}w`
  String date_format_week_ago(Object arg1) {
    return Intl.message(
      '${arg1}w',
      name: 'date_format_week_ago',
      desc: '',
      args: [arg1],
    );
  }

  /// `{arg1} month`
  String date_format_month_ago(Object arg1) {
    return Intl.message(
      '$arg1 month',
      name: 'date_format_month_ago',
      desc: '',
      args: [arg1],
    );
  }

  /// `{arg1} year`
  String date_format_year_ago(Object arg1) {
    return Intl.message(
      '$arg1 year',
      name: 'date_format_year_ago',
      desc: '',
      args: [arg1],
    );
  }

  /// `{arg1} minute ago`
  String date_format_minute_ago2(Object arg1) {
    return Intl.message(
      '$arg1 minute ago',
      name: 'date_format_minute_ago2',
      desc: '',
      args: [arg1],
    );
  }

  /// `{arg1} hour ago`
  String date_format_hour_ago2(Object arg1) {
    return Intl.message(
      '$arg1 hour ago',
      name: 'date_format_hour_ago2',
      desc: '',
      args: [arg1],
    );
  }

  /// `{arg1} day ago`
  String date_format_day_ago2(Object arg1) {
    return Intl.message(
      '$arg1 day ago',
      name: 'date_format_day_ago2',
      desc: '',
      args: [arg1],
    );
  }

  /// `{arg1} week ago`
  String date_format_week_ago2(Object arg1) {
    return Intl.message(
      '$arg1 week ago',
      name: 'date_format_week_ago2',
      desc: '',
      args: [arg1],
    );
  }

  /// `{arg1} month ago`
  String date_format_month_ago2(Object arg1) {
    return Intl.message(
      '$arg1 month ago',
      name: 'date_format_month_ago2',
      desc: '',
      args: [arg1],
    );
  }

  /// `{arg1} year ago`
  String date_format_year_ago2(Object arg1) {
    return Intl.message(
      '$arg1 year ago',
      name: 'date_format_year_ago2',
      desc: '',
      args: [arg1],
    );
  }

  /// `A new account will be created for you by incrementing the address index according to the bip44 specification.`
  String get message_account_group_creation_tips_1 {
    return Intl.message(
      'A new account will be created for you by incrementing the address index according to the bip44 specification.',
      name: 'message_account_group_creation_tips_1',
      desc: '',
      args: [],
    );
  }

  /// `The account created according to each index number is fixed, and you can still retrieve this account through the corresponding index number in other applications.`
  String get message_account_group_creation_tips_2 {
    return Intl.message(
      'The account created according to each index number is fixed, and you can still retrieve this account through the corresponding index number in other applications.',
      name: 'message_account_group_creation_tips_2',
      desc: '',
      args: [],
    );
  }

  /// `Creating for you...`
  String get message_creating_for_you {
    return Intl.message(
      'Creating for you...',
      name: 'message_creating_for_you',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get title_total {
    return Intl.message('Total', name: 'title_total', desc: '', args: []);
  }

  /// `Est. balance change`
  String get message_est_balance_change {
    return Intl.message(
      'Est. balance change',
      name: 'message_est_balance_change',
      desc: '',
      args: [],
    );
  }

  /// `Mint {arg1}`
  String title_format_mint_nft(Object arg1) {
    return Intl.message(
      'Mint $arg1',
      name: 'title_format_mint_nft',
      desc: '',
      args: [arg1],
    );
  }

  /// `Advanced`
  String get title_advanced {
    return Intl.message('Advanced', name: 'title_advanced', desc: '', args: []);
  }

  /// `Later`
  String get action_later {
    return Intl.message('Later', name: 'action_later', desc: '', args: []);
  }

  /// `Mint now`
  String get action_mint_now {
    return Intl.message(
      'Mint now',
      name: 'action_mint_now',
      desc: '',
      args: [],
    );
  }

  /// `Your tokens will appear here`
  String get message_empty_coin_assets {
    return Intl.message(
      'Your tokens will appear here',
      name: 'message_empty_coin_assets',
      desc: '',
      args: [],
    );
  }

  /// `Create new contact`
  String get action_create_new_contact {
    return Intl.message(
      'Create new contact',
      name: 'action_create_new_contact',
      desc: '',
      args: [],
    );
  }

  /// `You contacts are just a tap away here`
  String get message_empty_contacts {
    return Intl.message(
      'You contacts are just a tap away here',
      name: 'message_empty_contacts',
      desc: '',
      args: [],
    );
  }

  /// `Your NFT will appear here`
  String get message_empty_nft_assets {
    return Intl.message(
      'Your NFT will appear here',
      name: 'message_empty_nft_assets',
      desc: '',
      args: [],
    );
  }

  /// `NFT will be here`
  String get message_empty_user_nft_assets {
    return Intl.message(
      'NFT will be here',
      name: 'message_empty_user_nft_assets',
      desc: '',
      args: [],
    );
  }

  /// `To discover fun nft`
  String get action_to_discover_nft {
    return Intl.message(
      'To discover fun nft',
      name: 'action_to_discover_nft',
      desc: '',
      args: [],
    );
  }

  /// `Server Error: Http status [{arg1}]`
  String error_http_status_error(Object arg1) {
    return Intl.message(
      'Server Error: Http status [$arg1]',
      name: 'error_http_status_error',
      desc: '',
      args: [arg1],
    );
  }

  /// `Something went wrong, please try again later`
  String get error_default {
    return Intl.message(
      'Something went wrong, please try again later',
      name: 'error_default',
      desc: '',
      args: [],
    );
  }

  /// `Network connection failed, please try again later`
  String get error_connect {
    return Intl.message(
      'Network connection failed, please try again later',
      name: 'error_connect',
      desc: '',
      args: [],
    );
  }

  /// `Data format error, parsing failed`
  String get error_format {
    return Intl.message(
      'Data format error, parsing failed',
      name: 'error_format',
      desc: '',
      args: [],
    );
  }

  /// `Network connection timed out, please try again later`
  String get error_http_timeout {
    return Intl.message(
      'Network connection timed out, please try again later',
      name: 'error_http_timeout',
      desc: '',
      args: [],
    );
  }

  /// `No match`
  String get message_empty_search_result {
    return Intl.message(
      'No match',
      name: 'message_empty_search_result',
      desc: '',
      args: [],
    );
  }

  /// `Transaction details`
  String get title_transaction_details {
    return Intl.message(
      'Transaction details',
      name: 'title_transaction_details',
      desc: '',
      args: [],
    );
  }

  /// `Please review Puzzle's terms of service and privacy policy, then accept to continue.`
  String get message_terms_service_tip {
    return Intl.message(
      'Please review Puzzle\'s terms of service and privacy policy, then accept to continue.',
      name: 'message_terms_service_tip',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get title_password {
    return Intl.message('Password', name: 'title_password', desc: '', args: []);
  }

  /// `Use biometrics`
  String get title_use_biometrics {
    return Intl.message(
      'Use biometrics',
      name: 'title_use_biometrics',
      desc: '',
      args: [],
    );
  }

  /// `Activated`
  String get message_app_lock_activated {
    return Intl.message(
      'Activated',
      name: 'message_app_lock_activated',
      desc: '',
      args: [],
    );
  }

  /// `Inactivated`
  String get message_app_lock_inactivated {
    return Intl.message(
      'Inactivated',
      name: 'message_app_lock_inactivated',
      desc: '',
      args: [],
    );
  }

  /// `Could not find the backup file on the cloud storage service`
  String get message_backup_file_not_found_on_cloud {
    return Intl.message(
      'Could not find the backup file on the cloud storage service',
      name: 'message_backup_file_not_found_on_cloud',
      desc: '',
      args: [],
    );
  }

  /// `Choose wallet`
  String get title_choose_wallet_backup {
    return Intl.message(
      'Choose wallet',
      name: 'title_choose_wallet_backup',
      desc: '',
      args: [],
    );
  }

  /// `The backup file format is incorrect`
  String get message_backup_file_format_incorrect {
    return Intl.message(
      'The backup file format is incorrect',
      name: 'message_backup_file_format_incorrect',
      desc: '',
      args: [],
    );
  }

  /// `Failed to access cloud storage service`
  String get message_failed_access_cloud {
    return Intl.message(
      'Failed to access cloud storage service',
      name: 'message_failed_access_cloud',
      desc: '',
      args: [],
    );
  }

  /// `Recovery failed`
  String get message_wallet_recovery_failed_from_cloud {
    return Intl.message(
      'Recovery failed',
      name: 'message_wallet_recovery_failed_from_cloud',
      desc: '',
      args: [],
    );
  }

  /// `Google Drive`
  String get googleDrive {
    return Intl.message(
      'Google Drive',
      name: 'googleDrive',
      desc: '',
      args: [],
    );
  }

  /// `iCloud`
  String get icloud {
    return Intl.message('iCloud', name: 'icloud', desc: '', args: []);
  }

  /// `Backup file deletion failed`
  String get message_backup_file_delete_failed {
    return Intl.message(
      'Backup file deletion failed',
      name: 'message_backup_file_delete_failed',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get title_signature_info_message {
    return Intl.message(
      'Message',
      name: 'title_signature_info_message',
      desc: '',
      args: [],
    );
  }

  /// `Signed successfully`
  String get message_signed_successfully {
    return Intl.message(
      'Signed successfully',
      name: 'message_signed_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load data`
  String get message_failed_load_data {
    return Intl.message(
      'Failed to load data',
      name: 'message_failed_load_data',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load historical data`
  String get message_failed_load_history_data {
    return Intl.message(
      'Failed to load historical data',
      name: 'message_failed_load_history_data',
      desc: '',
      args: [],
    );
  }

  /// `Succeeded`
  String get succeeded {
    return Intl.message('Succeeded', name: 'succeeded', desc: '', args: []);
  }

  /// `Delete wallet`
  String get title_delete_wallet {
    return Intl.message(
      'Delete wallet',
      name: 'title_delete_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Enter a new wallet name`
  String get hint_wallet_name {
    return Intl.message(
      'Enter a new wallet name',
      name: 'hint_wallet_name',
      desc: '',
      args: [],
    );
  }

  /// `No records found`
  String get message_no_records_found {
    return Intl.message(
      'No records found',
      name: 'message_no_records_found',
      desc: '',
      args: [],
    );
  }

  /// `Save Photo`
  String get action_save_image {
    return Intl.message(
      'Save Photo',
      name: 'action_save_image',
      desc: '',
      args: [],
    );
  }

  /// `Saved to album`
  String get message_saved_to_album {
    return Intl.message(
      'Saved to album',
      name: 'message_saved_to_album',
      desc: '',
      args: [],
    );
  }

  /// `Save failed`
  String get message_save_failed {
    return Intl.message(
      'Save failed',
      name: 'message_save_failed',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get action_follow {
    return Intl.message('Follow', name: 'action_follow', desc: '', args: []);
  }

  /// `Unfollow`
  String get action_unfollow {
    return Intl.message(
      'Unfollow',
      name: 'action_unfollow',
      desc: '',
      args: [],
    );
  }

  /// `Following`
  String get message_followed {
    return Intl.message(
      'Following',
      name: 'message_followed',
      desc: '',
      args: [],
    );
  }

  /// `Following`
  String get title_following {
    return Intl.message(
      'Following',
      name: 'title_following',
      desc: '',
      args: [],
    );
  }

  /// `Unfollowed`
  String get message_unfollowed {
    return Intl.message(
      'Unfollowed',
      name: 'message_unfollowed',
      desc: '',
      args: [],
    );
  }

  /// `Wallet {arg1}`
  String format_wallet_default_name(Object arg1) {
    return Intl.message(
      'Wallet $arg1',
      name: 'format_wallet_default_name',
      desc: '',
      args: [arg1],
    );
  }

  /// `Follow failure`
  String get message_follow_failure {
    return Intl.message(
      'Follow failure',
      name: 'message_follow_failure',
      desc: '',
      args: [],
    );
  }

  /// `Enter password`
  String get hint_enter_password {
    return Intl.message(
      'Enter password',
      name: 'hint_enter_password',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get label_confirm_password {
    return Intl.message(
      'Confirm password',
      name: 'label_confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter the password again`
  String get hint_enter_password_again {
    return Intl.message(
      'Enter the password again',
      name: 'hint_enter_password_again',
      desc: '',
      args: [],
    );
  }

  /// `Please do not lose this password as it is not stored and we cannot reset it for you.`
  String get message_tip_backup_password_create {
    return Intl.message(
      'Please do not lose this password as it is not stored and we cannot reset it for you.',
      name: 'message_tip_backup_password_create',
      desc: '',
      args: [],
    );
  }

  /// `We require you to set a password for your Cloud backup. This is to ensure that only you can restore your wallet.`
  String get message_tip_backup_step1 {
    return Intl.message(
      'We require you to set a password for your Cloud backup. This is to ensure that only you can restore your wallet.',
      name: 'message_tip_backup_step1',
      desc: '',
      args: [],
    );
  }

  /// `Create password`
  String get title_create_password {
    return Intl.message(
      'Create password',
      name: 'title_create_password',
      desc: '',
      args: [],
    );
  }

  /// `I understand`
  String get action_i_understand {
    return Intl.message(
      'I understand',
      name: 'action_i_understand',
      desc: '',
      args: [],
    );
  }

  /// `To confirm that it is you who is accessing the backup file, enter your backup password.`
  String get message_tip_backup_password_decypt {
    return Intl.message(
      'To confirm that it is you who is accessing the backup file, enter your backup password.',
      name: 'message_tip_backup_password_decypt',
      desc: '',
      args: [],
    );
  }

  /// `Delete backup file`
  String get title_delete_backup_file {
    return Intl.message(
      'Delete backup file',
      name: 'title_delete_backup_file',
      desc: '',
      args: [],
    );
  }

  /// `Restore wallet`
  String get title_restore_wallet {
    return Intl.message(
      'Restore wallet',
      name: 'title_restore_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Cannot be empty`
  String get edit_error_not_empty {
    return Intl.message(
      'Cannot be empty',
      name: 'edit_error_not_empty',
      desc: '',
      args: [],
    );
  }

  /// `Length must be at least {arg1}`
  String edit_error_length(Object arg1) {
    return Intl.message(
      'Length must be at least $arg1',
      name: 'edit_error_length',
      desc: '',
      args: [arg1],
    );
  }

  /// `The two passwords entered are inconsistent`
  String get edit_error_password_confirm {
    return Intl.message(
      'The two passwords entered are inconsistent',
      name: 'edit_error_password_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password`
  String get edit_error_incorrect_password {
    return Intl.message(
      'Incorrect password',
      name: 'edit_error_incorrect_password',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Not available`
  String get message_not_available {
    return Intl.message(
      'Not available',
      name: 'message_not_available',
      desc: '',
      args: [],
    );
  }

  /// `Successful transaction`
  String get message_successful_transaction {
    return Intl.message(
      'Successful transaction',
      name: 'message_successful_transaction',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Preview`
  String get title_transaction_preview {
    return Intl.message(
      'Transaction Preview',
      name: 'title_transaction_preview',
      desc: '',
      args: [],
    );
  }

  /// `You have not allowed the application to access the camera and opening the scan failed.`
  String get message_scan_permission_set {
    return Intl.message(
      'You have not allowed the application to access the camera and opening the scan failed.',
      name: 'message_scan_permission_set',
      desc: '',
      args: [],
    );
  }

  /// `Newly active on thread`
  String get message_new_active_on_thread {
    return Intl.message(
      'Newly active on thread',
      name: 'message_new_active_on_thread',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get title_wallet_name {
    return Intl.message('Name', name: 'title_wallet_name', desc: '', args: []);
  }

  /// `Camera`
  String get action_camera {
    return Intl.message('Camera', name: 'action_camera', desc: '', args: []);
  }

  /// `Choose from photo album`
  String get action_pick_image_from_gallery {
    return Intl.message(
      'Choose from photo album',
      name: 'action_pick_image_from_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Use default avatar`
  String get action_use_default_avatar {
    return Intl.message(
      'Use default avatar',
      name: 'action_use_default_avatar',
      desc: '',
      args: [],
    );
  }

  /// `View on X`
  String get action_view_on_x {
    return Intl.message(
      'View on X',
      name: 'action_view_on_x',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get title_notifications {
    return Intl.message(
      'Notifications',
      name: 'title_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get hint_search {
    return Intl.message('Search', name: 'hint_search', desc: '', args: []);
  }

  /// `Price Unavailable`
  String get message_price_unavailable {
    return Intl.message(
      'Price Unavailable',
      name: 'message_price_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `You have already created this wallet, no need to create it again.`
  String get message_already_created_wallet {
    return Intl.message(
      'You have already created this wallet, no need to create it again.',
      name: 'message_already_created_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Push Notification`
  String get tip_push_notification_permission_title {
    return Intl.message(
      'Push Notification',
      name: 'tip_push_notification_permission_title',
      desc: '',
      args: [],
    );
  }

  /// `Never miss the next Alpha`
  String get tip_push_notification_permission_message {
    return Intl.message(
      'Never miss the next Alpha',
      name: 'tip_push_notification_permission_message',
      desc: '',
      args: [],
    );
  }

  /// `Another time`
  String get tip_push_notification_permission_message_negative {
    return Intl.message(
      'Another time',
      name: 'tip_push_notification_permission_message_negative',
      desc: '',
      args: [],
    );
  }

  /// `Turn on`
  String get tip_push_notification_permission_positive {
    return Intl.message(
      'Turn on',
      name: 'tip_push_notification_permission_positive',
      desc: '',
      args: [],
    );
  }

  /// `Existing wallet`
  String get title_existing_wallet {
    return Intl.message(
      'Existing wallet',
      name: 'title_existing_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Wallets`
  String get title_wallets {
    return Intl.message('Wallets', name: 'title_wallets', desc: '', args: []);
  }

  /// `Back up to {arg1}`
  String title_backup_to_cloud(Object arg1) {
    return Intl.message(
      'Back up to $arg1',
      name: 'title_backup_to_cloud',
      desc: '',
      args: [arg1],
    );
  }

  /// `Hot`
  String get hot {
    return Intl.message('Hot', name: 'hot', desc: '', args: []);
  }

  /// `Optional`
  String get optional {
    return Intl.message('Optional', name: 'optional', desc: '', args: []);
  }

  /// `New Pairs`
  String get new_coins {
    return Intl.message('New Pairs', name: 'new_coins', desc: '', args: []);
  }

  /// `Open`
  String get has_open {
    return Intl.message('Open', name: 'has_open', desc: '', args: []);
  }

  /// `WillOpen`
  String get will_open {
    return Intl.message('WillOpen', name: 'will_open', desc: '', args: []);
  }

  /// `NewCreate`
  String get new_create {
    return Intl.message('NewCreate', name: 'new_create', desc: '', args: []);
  }

  /// `Total assets`
  String get total_assets_value {
    return Intl.message(
      'Total assets',
      name: 'total_assets_value',
      desc: '',
      args: [],
    );
  }

  /// `Coins/{arg1}Volume`
  String coins_select_volume(Object arg1) {
    return Intl.message(
      'Coins/${arg1}Volume',
      name: 'coins_select_volume',
      desc: '',
      args: [arg1],
    );
  }

  /// `Market Cap`
  String get market_value {
    return Intl.message('Market Cap', name: 'market_value', desc: '', args: []);
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `{arg1}Change`
  String change(Object arg1) {
    return Intl.message(
      '${arg1}Change',
      name: 'change',
      desc: '',
      args: [arg1],
    );
  }

  /// `Priority fee`
  String get title_priority_fee {
    return Intl.message(
      'Priority fee',
      name: 'title_priority_fee',
      desc: '',
      args: [],
    );
  }

  /// `Trading`
  String get title_trading {
    return Intl.message('Trading', name: 'title_trading', desc: '', args: []);
  }

  /// `Search`
  String get title_search {
    return Intl.message('Search', name: 'title_search', desc: '', args: []);
  }

  /// `Insights`
  String get title_insights {
    return Intl.message('Insights', name: 'title_insights', desc: '', args: []);
  }

  /// `Rewards`
  String get title_rewards {
    return Intl.message('Rewards', name: 'title_rewards', desc: '', args: []);
  }

  /// `Assets`
  String get title_assets {
    return Intl.message('Assets', name: 'title_assets', desc: '', args: []);
  }

  /// `No backup files found`
  String get message_no_backup_files_found {
    return Intl.message(
      'No backup files found',
      name: 'message_no_backup_files_found',
      desc: '',
      args: [],
    );
  }

  /// `Wallet settings`
  String get title_wallet_settings {
    return Intl.message(
      'Wallet settings',
      name: 'title_wallet_settings',
      desc: '',
      args: [],
    );
  }

  /// `Cloud backup`
  String get title_cloud_backup {
    return Intl.message(
      'Cloud backup',
      name: 'title_cloud_backup',
      desc: '',
      args: [],
    );
  }

  /// `Delete backup`
  String get title_delete_backup {
    return Intl.message(
      'Delete backup',
      name: 'title_delete_backup',
      desc: '',
      args: [],
    );
  }

  /// `Sign In with {name}`
  String action_sign_in_cloud(Object name) {
    return Intl.message(
      'Sign In with $name',
      name: 'action_sign_in_cloud',
      desc: '',
      args: [name],
    );
  }

  /// `Backup to {name}`
  String action_backup_to_cloud(Object name) {
    return Intl.message(
      'Backup to $name',
      name: 'action_backup_to_cloud',
      desc: '',
      args: [name],
    );
  }

  /// `Please Sign In`
  String get title_please_sign_in {
    return Intl.message(
      'Please Sign In',
      name: 'title_please_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `To access your Google Drive backups,please sign in with your Google account.`
  String get message_please_sign_in_google_drive {
    return Intl.message(
      'To access your Google Drive backups,please sign in with your Google account.',
      name: 'message_please_sign_in_google_drive',
      desc: '',
      args: [],
    );
  }

  /// `Choose your backup method`
  String get title_choose_backup_method {
    return Intl.message(
      'Choose your backup method',
      name: 'title_choose_backup_method',
      desc: '',
      args: [],
    );
  }

  /// `This is how you will recover your wallet if you delete the app or lose your device.`
  String get message_backup_method_introduce {
    return Intl.message(
      'This is how you will recover your wallet if you delete the app or lose your device.',
      name: 'message_backup_method_introduce',
      desc: '',
      args: [],
    );
  }

  /// `Write down recovery phrase`
  String get title_write_down_phrase {
    return Intl.message(
      'Write down recovery phrase',
      name: 'title_write_down_phrase',
      desc: '',
      args: [],
    );
  }

  /// `Record your 12 secret words on a piece of paper and store it in a safe place.`
  String get message_write_down_phrase {
    return Intl.message(
      'Record your 12 secret words on a piece of paper and store it in a safe place.',
      name: 'message_write_down_phrase',
      desc: '',
      args: [],
    );
  }

  /// `back up your wallet via {name} , protected by a recovery password.`
  String message_backup_to_cloud_introduce(Object name) {
    return Intl.message(
      'back up your wallet via $name , protected by a recovery password.',
      name: 'message_backup_to_cloud_introduce',
      desc: '',
      args: [name],
    );
  }

  /// `Quick`
  String get label_quick {
    return Intl.message('Quick', name: 'label_quick', desc: '', args: []);
  }

  /// `Make your first deposit`
  String get empty_title_token_list {
    return Intl.message(
      'Make your first deposit',
      name: 'empty_title_token_list',
      desc: '',
      args: [],
    );
  }

  /// `Deposit solana to your address to start using your wallet.`
  String get empty_message_token_list {
    return Intl.message(
      'Deposit solana to your address to start using your wallet.',
      name: 'empty_message_token_list',
      desc: '',
      args: [],
    );
  }

  /// `No transactions yet`
  String get empty_title_transaction_list {
    return Intl.message(
      'No transactions yet',
      name: 'empty_title_transaction_list',
      desc: '',
      args: [],
    );
  }

  /// `your buys and sells will show up here.`
  String get empty_message_transaction_list {
    return Intl.message(
      'your buys and sells will show up here.',
      name: 'empty_message_transaction_list',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get title_trade_settings {
    return Intl.message(
      'Settings',
      name: 'title_trade_settings',
      desc: '',
      args: [],
    );
  }

  /// `Swipe to Sell`
  String get action_swipe_to_sell {
    return Intl.message(
      'Swipe to Sell',
      name: 'action_swipe_to_sell',
      desc: '',
      args: [],
    );
  }

  /// `Swipe to Buy`
  String get action_swipe_to_buy {
    return Intl.message(
      'Swipe to Buy',
      name: 'action_swipe_to_buy',
      desc: '',
      args: [],
    );
  }

  /// `Swipe to Send`
  String get action_swipe_to_send {
    return Intl.message(
      'Swipe to Send',
      name: 'action_swipe_to_send',
      desc: '',
      args: [],
    );
  }

  /// `Create a wallet`
  String get action_get_new_wallet {
    return Intl.message(
      'Create a wallet',
      name: 'action_get_new_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Add an existing wallet`
  String get action_add_existing_wallet {
    return Intl.message(
      'Add an existing wallet',
      name: 'action_add_existing_wallet',
      desc: '',
      args: [],
    );
  }

  /// `By continuing, you agree to Manic's Terms of Service and Privacy Policy.`
  String get terms_service_full {
    return Intl.message(
      'By continuing, you agree to Manic\'s Terms of Service and Privacy Policy.',
      name: 'terms_service_full',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get terms_service_link {
    return Intl.message(
      'Terms of Service',
      name: 'terms_service_link',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacy_policy_link {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy_link',
      desc: '',
      args: [],
    );
  }

  /// `Watchlist`
  String get watchlist {
    return Intl.message('Watchlist', name: 'watchlist', desc: '', args: []);
  }

  /// `Communities`
  String get communities {
    return Intl.message('Communities', name: 'communities', desc: '', args: []);
  }

  /// `Explorer`
  String get explorer {
    return Intl.message('Explorer', name: 'explorer', desc: '', args: []);
  }

  /// `Markets`
  String get markets {
    return Intl.message('Markets', name: 'markets', desc: '', args: []);
  }

  /// `Keep screen on`
  String get title_screen_auto_lock {
    return Intl.message(
      'Keep screen on',
      name: 'title_screen_auto_lock',
      desc: '',
      args: [],
    );
  }

  /// `Haptics`
  String get title_haptics {
    return Intl.message('Haptics', name: 'title_haptics', desc: '', args: []);
  }

  /// `Top Gainers`
  String get title_trending_up {
    return Intl.message(
      'Top Gainers',
      name: 'title_trending_up',
      desc: '',
      args: [],
    );
  }

  /// `TOKEN`
  String get market_list_header_token {
    return Intl.message(
      'TOKEN',
      name: 'market_list_header_token',
      desc: '',
      args: [],
    );
  }

  /// `TIME`
  String get market_list_header_time {
    return Intl.message(
      'TIME',
      name: 'market_list_header_time',
      desc: '',
      args: [],
    );
  }

  /// `VOLUME`
  String get market_list_header_volume {
    return Intl.message(
      'VOLUME',
      name: 'market_list_header_volume',
      desc: '',
      args: [],
    );
  }

  /// `MCAP`
  String get market_list_header_macp {
    return Intl.message(
      'MCAP',
      name: 'market_list_header_macp',
      desc: '',
      args: [],
    );
  }

  /// `PRICE`
  String get market_list_header_price {
    return Intl.message(
      'PRICE',
      name: 'market_list_header_price',
      desc: '',
      args: [],
    );
  }

  /// `CHG%`
  String get market_list_header_24h {
    return Intl.message(
      'CHG%',
      name: 'market_list_header_24h',
      desc: '',
      args: [],
    );
  }

  /// `Audit`
  String get title_audit {
    return Intl.message('Audit', name: 'title_audit', desc: '', args: []);
  }

  /// `Safe`
  String get status_audit_safe {
    return Intl.message('Safe', name: 'status_audit_safe', desc: '', args: []);
  }

  /// `Caution`
  String get status_audit_caution {
    return Intl.message(
      'Caution',
      name: 'status_audit_caution',
      desc: '',
      args: [],
    );
  }

  /// `Risk`
  String get status_audit_risk {
    return Intl.message('Risk', name: 'status_audit_risk', desc: '', args: []);
  }

  /// `Market Cap`
  String get market_ticker_label_mktcap {
    return Intl.message(
      'Market Cap',
      name: 'market_ticker_label_mktcap',
      desc: '',
      args: [],
    );
  }

  /// `Liquidity`
  String get market_ticker_label_liq {
    return Intl.message(
      'Liquidity',
      name: 'market_ticker_label_liq',
      desc: '',
      args: [],
    );
  }

  /// `24h Volume`
  String get market_ticker_label_vol {
    return Intl.message(
      '24h Volume',
      name: 'market_ticker_label_vol',
      desc: '',
      args: [],
    );
  }

  /// `24h Txns`
  String get market_ticker_label_txns {
    return Intl.message(
      '24h Txns',
      name: 'market_ticker_label_txns',
      desc: '',
      args: [],
    );
  }

  /// `Holders`
  String get market_ticker_label_holder {
    return Intl.message(
      'Holders',
      name: 'market_ticker_label_holder',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get market_ticker_label_price {
    return Intl.message(
      'Price',
      name: 'market_ticker_label_price',
      desc: '',
      args: [],
    );
  }

  /// `Recents`
  String get title_recents_viewed_market {
    return Intl.message(
      'Recents',
      name: 'title_recents_viewed_market',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get title_favorites_market {
    return Intl.message(
      'Favorites',
      name: 'title_favorites_market',
      desc: '',
      args: [],
    );
  }

  /// `No recents yet`
  String get empty_message_no_recents_1 {
    return Intl.message(
      'No recents yet',
      name: 'empty_message_no_recents_1',
      desc: '',
      args: [],
    );
  }

  /// `Your recently viewed tokens will be displayed here.`
  String get empty_message_no_recents_2 {
    return Intl.message(
      'Your recently viewed tokens will be displayed here.',
      name: 'empty_message_no_recents_2',
      desc: '',
      args: [],
    );
  }

  /// `No favorites yet`
  String get empty_message_no_favorites_1 {
    return Intl.message(
      'No favorites yet',
      name: 'empty_message_no_favorites_1',
      desc: '',
      args: [],
    );
  }

  /// `Your favorite tokens will be displayed here.`
  String get empty_message_no_favorites_2 {
    return Intl.message(
      'Your favorite tokens will be displayed here.',
      name: 'empty_message_no_favorites_2',
      desc: '',
      args: [],
    );
  }

  /// `Search tokens or CA...`
  String get hint_search_entry_field {
    return Intl.message(
      'Search tokens or CA...',
      name: 'hint_search_entry_field',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get title_logout {
    return Intl.message('Sign out', name: 'title_logout', desc: '', args: []);
  }

  /// `Discover Your Next Moonshot`
  String get title_wallet_start_tip1 {
    return Intl.message(
      'Discover Your Next Moonshot',
      name: 'title_wallet_start_tip1',
      desc: '',
      args: [],
    );
  }

  /// `Connect your wallet, seize every potential gem`
  String get title_wallet_start_tip2 {
    return Intl.message(
      'Connect your wallet, seize every potential gem',
      name: 'title_wallet_start_tip2',
      desc: '',
      args: [],
    );
  }

  /// `Connect Wallet Now`
  String get action_wallet_start_now {
    return Intl.message(
      'Connect Wallet Now',
      name: 'action_wallet_start_now',
      desc: '',
      args: [],
    );
  }

  /// `Disclaimer`
  String get title_disclaimer {
    return Intl.message(
      'Disclaimer',
      name: 'title_disclaimer',
      desc: '',
      args: [],
    );
  }

  /// `{appName} is not an exchange and does not provide investment advice. Nothing in this app constitutes investment advice or an offer, solicitation or recommendation of any kind. Users should make their own assessment of the risks involved and seek professional investment advice where necessary.\n\nCryptocurrencies and their related meme coins are not a traditional asset class and have no intrinsic value or use. They are for entertainment purposes only and should not be considered legal tender, investment vehicles or any form of store of value. The Modem Coin market is extremely volatile, prices can move drastically and unpredictably, and data displayed in the app may be subject to delays or errors.\n\nAll exchange transactions are completed through the blockchain, with funds going directly to the user's self-custody wallet. {appName} charges users a fee for buying and selling tokens, which may vary due to network congestion and fluctuating Gas rates.\n\n{appName} is a visual interface to blockchain decentralized exchanges and does not directly exchange, develop, create, maintain, or endorse any cryptocurrencies.`
  String disclaimerContent(Object appName) {
    return Intl.message(
      '$appName is not an exchange and does not provide investment advice. Nothing in this app constitutes investment advice or an offer, solicitation or recommendation of any kind. Users should make their own assessment of the risks involved and seek professional investment advice where necessary.\n\nCryptocurrencies and their related meme coins are not a traditional asset class and have no intrinsic value or use. They are for entertainment purposes only and should not be considered legal tender, investment vehicles or any form of store of value. The Modem Coin market is extremely volatile, prices can move drastically and unpredictably, and data displayed in the app may be subject to delays or errors.\n\nAll exchange transactions are completed through the blockchain, with funds going directly to the user\'s self-custody wallet. $appName charges users a fee for buying and selling tokens, which may vary due to network congestion and fluctuating Gas rates.\n\n$appName is a visual interface to blockchain decentralized exchanges and does not directly exchange, develop, create, maintain, or endorse any cryptocurrencies.',
      name: 'disclaimerContent',
      desc: '',
      args: [appName],
    );
  }

  /// `Sell price`
  String get sell_price {
    return Intl.message('Sell price', name: 'sell_price', desc: '', args: []);
  }

  /// `Buy price`
  String get buy_price {
    return Intl.message('Buy price', name: 'buy_price', desc: '', args: []);
  }

  /// `Sell amount`
  String get sell_amount {
    return Intl.message('Sell amount', name: 'sell_amount', desc: '', args: []);
  }

  /// `Buy amount`
  String get buy_amount {
    return Intl.message('Buy amount', name: 'buy_amount', desc: '', args: []);
  }

  /// `Total Balance`
  String get title_total_balance {
    return Intl.message(
      'Total Balance',
      name: 'title_total_balance',
      desc: '',
      args: [],
    );
  }

  /// `All time`
  String get title_all_time {
    return Intl.message('All time', name: 'title_all_time', desc: '', args: []);
  }

  /// `Import with Recovery Phrase`
  String get title_wallet_import {
    return Intl.message(
      'Import with Recovery Phrase',
      name: 'title_wallet_import',
      desc: '',
      args: [],
    );
  }

  /// `Enter your recovery phrase below. It is comprised of 12 or 24 words.`
  String get message_wallet_import_description {
    return Intl.message(
      'Enter your recovery phrase below. It is comprised of 12 or 24 words.',
      name: 'message_wallet_import_description',
      desc: '',
      args: [],
    );
  }

  /// `Restore a wallet`
  String get title_wallet_restore {
    return Intl.message(
      'Restore a wallet',
      name: 'title_wallet_restore',
      desc: '',
      args: [],
    );
  }

  /// `Restore your wallet from {cloudType} to regain access to your digital assets.`
  String message_wallet_restore_description(Object cloudType) {
    return Intl.message(
      'Restore your wallet from $cloudType to regain access to your digital assets.',
      name: 'message_wallet_restore_description',
      desc: '',
      args: [cloudType],
    );
  }

  /// `Edit name`
  String get action_edit_name {
    return Intl.message(
      'Edit name',
      name: 'action_edit_name',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction may have timed out.`
  String get message_transfer_timeout {
    return Intl.message(
      'Your transaction may have timed out.',
      name: 'message_transfer_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction failed.`
  String get message_transfer_failed {
    return Intl.message(
      'Your transaction failed.',
      name: 'message_transfer_failed',
      desc: '',
      args: [],
    );
  }

  /// `View on Solscan`
  String get action_view_on_solscan {
    return Intl.message(
      'View on Solscan',
      name: 'action_view_on_solscan',
      desc: '',
      args: [],
    );
  }

  /// `Building transaction...`
  String get message_transfer_building {
    return Intl.message(
      'Building transaction...',
      name: 'message_transfer_building',
      desc: '',
      args: [],
    );
  }

  /// `Getting quote...`
  String get message_quote_getting {
    return Intl.message(
      'Getting quote...',
      name: 'message_quote_getting',
      desc: '',
      args: [],
    );
  }

  /// `Transaction successful`
  String get message_transfer_success {
    return Intl.message(
      'Transaction successful',
      name: 'message_transfer_success',
      desc: '',
      args: [],
    );
  }

  /// `Sent. Waiting for confirmation...`
  String get message_transfer_pending {
    return Intl.message(
      'Sent. Waiting for confirmation...',
      name: 'message_transfer_pending',
      desc: '',
      args: [],
    );
  }

  /// `Transaction sent, waiting for confirmation`
  String get message_transfer_pending_toast {
    return Intl.message(
      'Transaction sent, waiting for confirmation',
      name: 'message_transfer_pending_toast',
      desc: '',
      args: [],
    );
  }

  /// `Transaction cancelled`
  String get message_transfer_cancelled {
    return Intl.message(
      'Transaction cancelled',
      name: 'message_transfer_cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get quote. Please try again...`
  String get message_transfer_quote_failed {
    return Intl.message(
      'Failed to get quote. Please try again...',
      name: 'message_transfer_quote_failed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to build transaction. Please try again...`
  String get message_transfer_build_failed {
    return Intl.message(
      'Failed to build transaction. Please try again...',
      name: 'message_transfer_build_failed',
      desc: '',
      args: [],
    );
  }

  /// `Invalid address`
  String get message_transfer_invalid_address {
    return Intl.message(
      'Invalid address',
      name: 'message_transfer_invalid_address',
      desc: '',
      args: [],
    );
  }

  /// `Scan QR Code`
  String get title_transfer_scan_qr {
    return Intl.message(
      'Scan QR Code',
      name: 'title_transfer_scan_qr',
      desc: '',
      args: [],
    );
  }

  /// `Tap to scan an address`
  String get message_transfer_scan_qr_tip {
    return Intl.message(
      'Tap to scan an address',
      name: 'message_transfer_scan_qr_tip',
      desc: '',
      args: [],
    );
  }

  /// `MAX`
  String get title_transfer_percentage_max {
    return Intl.message(
      'MAX',
      name: 'title_transfer_percentage_max',
      desc: '',
      args: [],
    );
  }

  /// `Wallet Not Initialized`
  String get title_wallet_not_initialized {
    return Intl.message(
      'Wallet Not Initialized',
      name: 'title_wallet_not_initialized',
      desc: '',
      args: [],
    );
  }

  /// `Once set up, you'll enjoy faster transactions, real-time market insights, and advanced analytics.`
  String get message_wallet_not_initialized {
    return Intl.message(
      'Once set up, you\'ll enjoy faster transactions, real-time market insights, and advanced analytics.',
      name: 'message_wallet_not_initialized',
      desc: '',
      args: [],
    );
  }

  /// `Setup wallet`
  String get action_setup_wallet {
    return Intl.message(
      'Setup wallet',
      name: 'action_setup_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Login failed`
  String get message_login_failed {
    return Intl.message(
      'Login failed',
      name: 'message_login_failed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get backup files`
  String get message_get_backup_files_failed {
    return Intl.message(
      'Failed to get backup files',
      name: 'message_get_backup_files_failed',
      desc: '',
      args: [],
    );
  }

  /// `Cumulative P&L`
  String get title_total_profit_and_loss {
    return Intl.message(
      'Cumulative P&L',
      name: 'title_total_profit_and_loss',
      desc: '',
      args: [],
    );
  }

  /// `Content copied to clipboard`
  String get message_copied_to_clipboard {
    return Intl.message(
      'Content copied to clipboard',
      name: 'message_copied_to_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Disclaimer: The above content is from scan results, for reference only.`
  String get message_scan_result_disclaimer {
    return Intl.message(
      'Disclaimer: The above content is from scan results, for reference only.',
      name: 'message_scan_result_disclaimer',
      desc: '',
      args: [],
    );
  }

  /// `Bought {symbol}`
  String title_transaction_bought(Object symbol) {
    return Intl.message(
      'Bought $symbol',
      name: 'title_transaction_bought',
      desc: '',
      args: [symbol],
    );
  }

  /// `Sold {symbol}`
  String title_transaction_sold(Object symbol) {
    return Intl.message(
      'Sold $symbol',
      name: 'title_transaction_sold',
      desc: '',
      args: [symbol],
    );
  }

  /// `Sent`
  String get title_transaction_sent {
    return Intl.message(
      'Sent',
      name: 'title_transaction_sent',
      desc: '',
      args: [],
    );
  }

  /// `Received`
  String get title_transaction_received {
    return Intl.message(
      'Received',
      name: 'title_transaction_received',
      desc: '',
      args: [],
    );
  }

  /// `Txn`
  String get title_transaction_hash {
    return Intl.message(
      'Txn',
      name: 'title_transaction_hash',
      desc: '',
      args: [],
    );
  }

  /// `Value`
  String get label_value {
    return Intl.message('Value', name: 'label_value', desc: '', args: []);
  }

  /// `Holdings`
  String get label_holdings {
    return Intl.message('Holdings', name: 'label_holdings', desc: '', args: []);
  }

  /// `P/L`
  String get label_profit_loss {
    return Intl.message('P/L', name: 'label_profit_loss', desc: '', args: []);
  }

  /// `Unrealized P/L`
  String get label_holding_profit_loss_pct {
    return Intl.message(
      'Unrealized P/L',
      name: 'label_holding_profit_loss_pct',
      desc: '',
      args: [],
    );
  }

  /// `All time gains`
  String get label_total_profit_loss_pct {
    return Intl.message(
      'All time gains',
      name: 'label_total_profit_loss_pct',
      desc: '',
      args: [],
    );
  }

  /// `Balance:`
  String get flag_balance {
    return Intl.message('Balance:', name: 'flag_balance', desc: '', args: []);
  }

  /// `y`
  String get time_unit_year {
    return Intl.message('y', name: 'time_unit_year', desc: '', args: []);
  }

  /// `mo`
  String get time_unit_month {
    return Intl.message('mo', name: 'time_unit_month', desc: '', args: []);
  }

  /// `d`
  String get time_unit_day {
    return Intl.message('d', name: 'time_unit_day', desc: '', args: []);
  }

  /// `h`
  String get time_unit_hour {
    return Intl.message('h', name: 'time_unit_hour', desc: '', args: []);
  }

  /// `m`
  String get time_unit_minute {
    return Intl.message('m', name: 'time_unit_minute', desc: '', args: []);
  }

  /// `Auto`
  String get auto {
    return Intl.message('Auto', name: 'auto', desc: '', args: []);
  }

  /// `Custom`
  String get custom {
    return Intl.message('Custom', name: 'custom', desc: '', args: []);
  }

  /// `Custom:`
  String get flag_custom {
    return Intl.message('Custom:', name: 'flag_custom', desc: '', args: []);
  }

  /// `Slippage`
  String get title_slippage {
    return Intl.message('Slippage', name: 'title_slippage', desc: '', args: []);
  }

  /// `Set the maximum acceptable price change during trading.`
  String get message_slippage_description {
    return Intl.message(
      'Set the maximum acceptable price change during trading.',
      name: 'message_slippage_description',
      desc: '',
      args: [],
    );
  }

  /// `Minimum trade amount for {symbol}: {value}`
  String message_swap_min_amount(Object symbol, Object value) {
    return Intl.message(
      'Minimum trade amount for $symbol: $value',
      name: 'message_swap_min_amount',
      desc: '',
      args: [symbol, value],
    );
  }

  /// `Switch Wallet`
  String get action_switch_wallet {
    return Intl.message(
      'Switch Wallet',
      name: 'action_switch_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Switch`
  String get action_switch_wallet_short {
    return Intl.message(
      'Switch',
      name: 'action_switch_wallet_short',
      desc: '',
      args: [],
    );
  }

  /// `Copied!`
  String get message_copy_success {
    return Intl.message(
      'Copied!',
      name: 'message_copy_success',
      desc: '',
      args: [],
    );
  }

  /// `Share gains`
  String get action_share_gains {
    return Intl.message(
      'Share gains',
      name: 'action_share_gains',
      desc: '',
      args: [],
    );
  }

  /// `Since`
  String get flag_since {
    return Intl.message('Since', name: 'flag_since', desc: '', args: []);
  }

  /// `with`
  String get flag_with {
    return Intl.message('with', name: 'flag_with', desc: '', args: []);
  }

  /// `Save successfully`
  String get message_save_success {
    return Intl.message(
      'Save successfully',
      name: 'message_save_success',
      desc: '',
      args: [],
    );
  }

  /// `Reset successfully`
  String get message_reset_success {
    return Intl.message(
      'Reset successfully',
      name: 'message_reset_success',
      desc: '',
      args: [],
    );
  }

  /// `Background`
  String get background {
    return Intl.message('Background', name: 'background', desc: '', args: []);
  }

  /// `Transparency`
  String get transparency {
    return Intl.message(
      'Transparency',
      name: 'transparency',
      desc: '',
      args: [],
    );
  }

  /// `Manage tokens`
  String get action_manage_tokens {
    return Intl.message(
      'Manage tokens',
      name: 'action_manage_tokens',
      desc: '',
      args: [],
    );
  }

  /// `Your holdings will be displayed here.`
  String get empty_message_holding_tokens {
    return Intl.message(
      'Your holdings will be displayed here.',
      name: 'empty_message_holding_tokens',
      desc: '',
      args: [],
    );
  }

  /// `SINCE`
  String get profit_loss_list_header_time {
    return Intl.message(
      'SINCE',
      name: 'profit_loss_list_header_time',
      desc: '',
      args: [],
    );
  }

  /// `P/L`
  String get profit_loss_list_header_change {
    return Intl.message(
      'P/L',
      name: 'profit_loss_list_header_change',
      desc: '',
      args: [],
    );
  }

  /// `P/L%`
  String get profit_loss_list_header_change_rate {
    return Intl.message(
      'P/L%',
      name: 'profit_loss_list_header_change_rate',
      desc: '',
      args: [],
    );
  }

  /// `Holding`
  String get label_holding {
    return Intl.message('Holding', name: 'label_holding', desc: '', args: []);
  }

  /// `MCap`
  String get k_setting_bar_mcap {
    return Intl.message('MCap', name: 'k_setting_bar_mcap', desc: '', args: []);
  }

  /// `Price`
  String get k_setting_bar_price {
    return Intl.message(
      'Price',
      name: 'k_setting_bar_price',
      desc: '',
      args: [],
    );
  }

  /// `Market cap`
  String get k_based_mcap_select_mcap {
    return Intl.message(
      'Market cap',
      name: 'k_based_mcap_select_mcap',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get k_based_mcap_select_price {
    return Intl.message(
      'Price',
      name: 'k_based_mcap_select_price',
      desc: '',
      args: [],
    );
  }

  /// `Show market cap first`
  String get title_preference_first_macp {
    return Intl.message(
      'Show market cap first',
      name: 'title_preference_first_macp',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get k_scale_position_auto {
    return Intl.message(
      'Auto',
      name: 'k_scale_position_auto',
      desc: '',
      args: [],
    );
  }

  /// `Left`
  String get k_scale_position_left {
    return Intl.message(
      'Left',
      name: 'k_scale_position_left',
      desc: '',
      args: [],
    );
  }

  /// `Middle`
  String get k_scale_position_middle {
    return Intl.message(
      'Middle',
      name: 'k_scale_position_middle',
      desc: '',
      args: [],
    );
  }

  /// `Right`
  String get k_scale_position_right {
    return Intl.message(
      'Right',
      name: 'k_scale_position_right',
      desc: '',
      args: [],
    );
  }

  /// `Scale position`
  String get k_title_scale_position {
    return Intl.message(
      'Scale position',
      name: 'k_title_scale_position',
      desc: '',
      args: [],
    );
  }

  /// `Zoom style`
  String get k_title_zoom_style {
    return Intl.message(
      'Zoom style',
      name: 'k_title_zoom_style',
      desc: '',
      args: [],
    );
  }

  /// `Bullish`
  String get k_title_bullish {
    return Intl.message('Bullish', name: 'k_title_bullish', desc: '', args: []);
  }

  /// `Bearish`
  String get k_title_bearish {
    return Intl.message('Bearish', name: 'k_title_bearish', desc: '', args: []);
  }

  /// `Multiple main indicator`
  String get k_title_multi_main_indicator {
    return Intl.message(
      'Multiple main indicator',
      name: 'k_title_multi_main_indicator',
      desc: '',
      args: [],
    );
  }

  /// `Double tap full screen`
  String get k_title_double_tap_full_screen {
    return Intl.message(
      'Double tap full screen',
      name: 'k_title_double_tap_full_screen',
      desc: '',
      args: [],
    );
  }

  /// `Drag zoom Y axis`
  String get k_title_drag_zoom_y_axis {
    return Intl.message(
      'Drag zoom Y axis',
      name: 'k_title_drag_zoom_y_axis',
      desc: '',
      args: [],
    );
  }

  /// `Drag indicator height`
  String get k_title_drag_indicator_height {
    return Intl.message(
      'Drag indicator height',
      name: 'k_title_drag_indicator_height',
      desc: '',
      args: [],
    );
  }

  /// `Chart style`
  String get k_title_chart_style {
    return Intl.message(
      'Chart style',
      name: 'k_title_chart_style',
      desc: '',
      args: [],
    );
  }

  /// `Chart interaction`
  String get k_title_chart_interaction {
    return Intl.message(
      'Chart interaction',
      name: 'k_title_chart_interaction',
      desc: '',
      args: [],
    );
  }

  /// `No profit and loss records`
  String get empty_message_no_profit_loss_1 {
    return Intl.message(
      'No profit and loss records',
      name: 'empty_message_no_profit_loss_1',
      desc: '',
      args: [],
    );
  }

  /// `After trading, your profit and loss records will be displayed here`
  String get empty_message_no_profit_loss_2 {
    return Intl.message(
      'After trading, your profit and loss records will be displayed here',
      name: 'empty_message_no_profit_loss_2',
      desc: '',
      args: [],
    );
  }

  /// `Holdings`
  String get title_holdings {
    return Intl.message('Holdings', name: 'title_holdings', desc: '', args: []);
  }

  /// `Quantity`
  String get title_quantity {
    return Intl.message('Quantity', name: 'title_quantity', desc: '', args: []);
  }

  /// `First Buy`
  String get title_first_buy {
    return Intl.message(
      'First Buy',
      name: 'title_first_buy',
      desc: '',
      args: [],
    );
  }

  /// `Total Gains`
  String get title_total_gains {
    return Intl.message(
      'Total Gains',
      name: 'title_total_gains',
      desc: '',
      args: [],
    );
  }

  /// `Account Rent Recovery`
  String get title_account_rent_recovery {
    return Intl.message(
      'Account Rent Recovery',
      name: 'title_account_rent_recovery',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get label_wallet {
    return Intl.message('Wallet', name: 'label_wallet', desc: '', args: []);
  }

  /// `Claimable Rent`
  String get label_claimable_rent {
    return Intl.message(
      'Claimable Rent',
      name: 'label_claimable_rent',
      desc: '',
      args: [],
    );
  }

  /// `Remaining Claimable Rent`
  String get label_remaining_claimable_rent {
    return Intl.message(
      'Remaining Claimable Rent',
      name: 'label_remaining_claimable_rent',
      desc: '',
      args: [],
    );
  }

  /// `{arg1} accounts`
  String label_accounts_count(Object arg1) {
    return Intl.message(
      '$arg1 accounts',
      name: 'label_accounts_count',
      desc: '',
      args: [arg1],
    );
  }

  /// `Maximum {arg1} accounts can be recovered at once. You can recover multiple times to claim all remaining rent.`
  String message_max_accounts_per_recovery(Object arg1) {
    return Intl.message(
      'Maximum $arg1 accounts can be recovered at once. You can recover multiple times to claim all remaining rent.',
      name: 'message_max_accounts_per_recovery',
      desc: '',
      args: [arg1],
    );
  }

  /// `Swipe to Claim`
  String get action_slide_to_claim {
    return Intl.message(
      'Swipe to Claim',
      name: 'action_slide_to_claim',
      desc: '',
      args: [],
    );
  }

  /// `No results found`
  String get message_no_results_found {
    return Intl.message(
      'No results found',
      name: 'message_no_results_found',
      desc: '',
      args: [],
    );
  }

  /// `Please try again with a different search term.`
  String get message_try_different_search {
    return Intl.message(
      'Please try again with a different search term.',
      name: 'message_try_different_search',
      desc: '',
      args: [],
    );
  }

  /// `Recent`
  String get title_transfer_recent_addresses {
    return Intl.message(
      'Recent',
      name: 'title_transfer_recent_addresses',
      desc: '',
      args: [],
    );
  }

  /// `My Wallet`
  String get title_transfer_my_wallet {
    return Intl.message(
      'My Wallet',
      name: 'title_transfer_my_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Address Book`
  String get title_transfer_address_book {
    return Intl.message(
      'Address Book',
      name: 'title_transfer_address_book',
      desc: '',
      args: [],
    );
  }

  /// `Supports all Solana tokens\n(SOL, USDC, USDT, etc.)`
  String get message_receive_all_solana_assets {
    return Intl.message(
      'Supports all Solana tokens\n(SOL, USDC, USDT, etc.)',
      name: 'message_receive_all_solana_assets',
      desc: '',
      args: [],
    );
  }

  /// `Only supports receiving {networkName} assets`
  String message_only_receive_network_assets(Object networkName) {
    return Intl.message(
      'Only supports receiving $networkName assets',
      name: 'message_only_receive_network_assets',
      desc: '',
      args: [networkName],
    );
  }

  /// `Go to Trade`
  String get action_go_to_trade {
    return Intl.message(
      'Go to Trade',
      name: 'action_go_to_trade',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get title_description {
    return Intl.message(
      'Description',
      name: 'title_description',
      desc: '',
      args: [],
    );
  }

  /// `Since Listed`
  String get title_since_listed {
    return Intl.message(
      'Since Listed',
      name: 'title_since_listed',
      desc: '',
      args: [],
    );
  }

  /// `Feed`
  String get title_feed {
    return Intl.message('Feed', name: 'title_feed', desc: '', args: []);
  }

  /// `Listed`
  String get title_listed {
    return Intl.message('Listed', name: 'title_listed', desc: '', args: []);
  }

  /// `No token found`
  String get message_search_entry_field_not_found {
    return Intl.message(
      'No token found',
      name: 'message_search_entry_field_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Searching for token...`
  String get message_search_entry_field_loading {
    return Intl.message(
      'Searching for token...',
      name: 'message_search_entry_field_loading',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get action_clear {
    return Intl.message('Clear', name: 'action_clear', desc: '', args: []);
  }

  /// `Cash`
  String get title_cash {
    return Intl.message('Cash', name: 'title_cash', desc: '', args: []);
  }

  /// `Positions`
  String get title_positions {
    return Intl.message(
      'Positions',
      name: 'title_positions',
      desc: '',
      args: [],
    );
  }

  /// `Active Trades`
  String get title_active_trades {
    return Intl.message(
      'Active Trades',
      name: 'title_active_trades',
      desc: '',
      args: [],
    );
  }

  /// `Trading History`
  String get title_trading_history {
    return Intl.message(
      'Trading History',
      name: 'title_trading_history',
      desc: '',
      args: [],
    );
  }

  /// `Reclaim`
  String get action_reclaim {
    return Intl.message('Reclaim', name: 'action_reclaim', desc: '', args: []);
  }

  /// `Update Available`
  String get title_update_available {
    return Intl.message(
      'Update Available',
      name: 'title_update_available',
      desc: '',
      args: [],
    );
  }

  /// `The new version has been downloaded and will restart after installation. It is recommended to save your current work before installation.`
  String get message_update_available {
    return Intl.message(
      'The new version has been downloaded and will restart after installation. It is recommended to save your current work before installation.',
      name: 'message_update_available',
      desc: '',
      args: [],
    );
  }

  /// `Later`
  String get action_update_later {
    return Intl.message(
      'Later',
      name: 'action_update_later',
      desc: '',
      args: [],
    );
  }

  /// `Install Now`
  String get action_update_now {
    return Intl.message(
      'Install Now',
      name: 'action_update_now',
      desc: '',
      args: [],
    );
  }

  /// `Swap to`
  String get title_swap_to {
    return Intl.message('Swap to', name: 'title_swap_to', desc: '', args: []);
  }

  /// `Invite frens`
  String get title_invite_frens {
    return Intl.message(
      'Invite frens',
      name: 'title_invite_frens',
      desc: '',
      args: [],
    );
  }

  /// `Lifetime rewards`
  String get title_lifetime_rewards {
    return Intl.message(
      'Lifetime rewards',
      name: 'title_lifetime_rewards',
      desc: '',
      args: [],
    );
  }

  /// `Frens referred`
  String get title_frens_referred {
    return Intl.message(
      'Frens referred',
      name: 'title_frens_referred',
      desc: '',
      args: [],
    );
  }

  /// `Rewards are issued in USDC, a stablecoin backed by real assets, ensuring value stability.`
  String get message_rewards_are_issued_in_usdc {
    return Intl.message(
      'Rewards are issued in USDC, a stablecoin backed by real assets, ensuring value stability.',
      name: 'message_rewards_are_issued_in_usdc',
      desc: '',
      args: [],
    );
  }

  /// `Get cash whenever your frens\nand their frens trade`
  String get message_invite_frens_tips {
    return Intl.message(
      'Get cash whenever your frens\nand their frens trade',
      name: 'message_invite_frens_tips',
      desc: '',
      args: [],
    );
  }

  /// `Get Manic Trade with my link: {url}`
  String message_invite_frens_share(Object url) {
    return Intl.message(
      'Get Manic Trade with my link: $url',
      name: 'message_invite_frens_share',
      desc: '',
      args: [url],
    );
  }

  /// `Invite friends to win rewards`
  String get message_reward_no_wallet_title {
    return Intl.message(
      'Invite friends to win rewards',
      name: 'message_reward_no_wallet_title',
      desc: '',
      args: [],
    );
  }

  /// `Connect your wallet to invite friends and earn rewards`
  String get message_reward_no_wallet_desc {
    return Intl.message(
      'Connect your wallet to invite friends and earn rewards',
      name: 'message_reward_no_wallet_desc',
      desc: '',
      args: [],
    );
  }

  /// `Cleared`
  String get message_cleared {
    return Intl.message('Cleared', name: 'message_cleared', desc: '', args: []);
  }

  /// `Open P&L`
  String get title_position_pnl {
    return Intl.message(
      'Open P&L',
      name: 'title_position_pnl',
      desc: '',
      args: [],
    );
  }

  /// `Invalid mnemonic phrase`
  String get message_mnemonic_invalid {
    return Intl.message(
      'Invalid mnemonic phrase',
      name: 'message_mnemonic_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Invalid private key`
  String get message_private_key_invalid {
    return Intl.message(
      'Invalid private key',
      name: 'message_private_key_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Import Private Key`
  String get title_import_private_key {
    return Intl.message(
      'Import Private Key',
      name: 'title_import_private_key',
      desc: '',
      args: [],
    );
  }

  /// `Private Key`
  String get title_private_key {
    return Intl.message(
      'Private Key',
      name: 'title_private_key',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your private key, usually consisting of 64 letters or numbers.`
  String get message_import_private_key_description {
    return Intl.message(
      'Please enter your private key, usually consisting of 64 letters or numbers.',
      name: 'message_import_private_key_description',
      desc: '',
      args: [],
    );
  }

  /// `Enter your private key`
  String get hint_enter_private_key {
    return Intl.message(
      'Enter your private key',
      name: 'hint_enter_private_key',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for using {appName}!\nYour feedback is very important to us.`
  String message_rate_my_app_description(Object appName) {
    return Intl.message(
      'Thank you for using $appName!\nYour feedback is very important to us.',
      name: 'message_rate_my_app_description',
      desc: '',
      args: [appName],
    );
  }

  /// `Rate in the store`
  String get action_rate_my_app_rate {
    return Intl.message(
      'Rate in the store',
      name: 'action_rate_my_app_rate',
      desc: '',
      args: [],
    );
  }

  /// `Remind me later`
  String get action_rate_my_app_later {
    return Intl.message(
      'Remind me later',
      name: 'action_rate_my_app_later',
      desc: '',
      args: [],
    );
  }

  /// `No, thanks`
  String get action_rate_my_app_dismiss {
    return Intl.message(
      'No, thanks',
      name: 'action_rate_my_app_dismiss',
      desc: '',
      args: [],
    );
  }

  /// `Referral Reward`
  String get title_referral_reward {
    return Intl.message(
      'Referral Reward',
      name: 'title_referral_reward',
      desc: '',
      args: [],
    );
  }

  /// `Rent Recovery`
  String get title_rent_recovery {
    return Intl.message(
      'Rent Recovery',
      name: 'title_rent_recovery',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get title_amount {
    return Intl.message('Amount', name: 'title_amount', desc: '', args: []);
  }

  /// `Enter your recovery phrase`
  String get hint_enter_recovery_phrase {
    return Intl.message(
      'Enter your recovery phrase',
      name: 'hint_enter_recovery_phrase',
      desc: '',
      args: [],
    );
  }

  /// `Time `
  String get trade_history_label_time {
    return Intl.message(
      'Time ',
      name: 'trade_history_label_time',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get trade_history_label_price {
    return Intl.message(
      'Price',
      name: 'trade_history_label_price',
      desc: '',
      args: [],
    );
  }

  /// `Volume($)`
  String get trade_history_label_volume {
    return Intl.message(
      'Volume(\$)',
      name: 'trade_history_label_volume',
      desc: '',
      args: [],
    );
  }

  /// `Real-time transactions will be displayed here`
  String get message_trade_history_empty {
    return Intl.message(
      'Real-time transactions will be displayed here',
      name: 'message_trade_history_empty',
      desc: '',
      args: [],
    );
  }

  /// `Airdrop`
  String get title_airdrop {
    return Intl.message('Airdrop', name: 'title_airdrop', desc: '', args: []);
  }

  /// `Trade`
  String get title_trade {
    return Intl.message('Trade', name: 'title_trade', desc: '', args: []);
  }

  /// `Submit Feedback`
  String get feedback_title {
    return Intl.message(
      'Submit Feedback',
      name: 'feedback_title',
      desc: '',
      args: [],
    );
  }

  /// `Please describe your feedback or issue...`
  String get feedback_hint {
    return Intl.message(
      'Please describe your feedback or issue...',
      name: 'feedback_hint',
      desc: '',
      args: [],
    );
  }

  /// `Add Image`
  String get feedback_add_image {
    return Intl.message(
      'Add Image',
      name: 'feedback_add_image',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get feedback_send {
    return Intl.message('Send', name: 'feedback_send', desc: '', args: []);
  }

  /// `Please enter feedback content`
  String get feedback_content_empty {
    return Intl.message(
      'Please enter feedback content',
      name: 'feedback_content_empty',
      desc: '',
      args: [],
    );
  }

  /// `Maximum 5 images allowed`
  String get feedback_max_images_reached {
    return Intl.message(
      'Maximum 5 images allowed',
      name: 'feedback_max_images_reached',
      desc: '',
      args: [],
    );
  }

  /// `Feedback submitted successfully`
  String get feedback_submit_success {
    return Intl.message(
      'Feedback submitted successfully',
      name: 'feedback_submit_success',
      desc: '',
      args: [],
    );
  }

  /// `This image has already been added`
  String get feedback_image_already_added {
    return Intl.message(
      'This image has already been added',
      name: 'feedback_image_already_added',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get title_balance {
    return Intl.message('Balance', name: 'title_balance', desc: '', args: []);
  }

  /// `Recent Trades`
  String get title_recent_trades {
    return Intl.message(
      'Recent Trades',
      name: 'title_recent_trades',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get view_all {
    return Intl.message('View All', name: 'view_all', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
