import 'package:drift/drift.dart';
import 'package:finality/data/drift/converters/options_converter.dart';

/// 期权交易对
class OptionsTradingPairs extends Table {
  /// 交易对ID
  TextColumn get feedId => text()();

  /// 基础资产符号
  TextColumn get baseAsset => text()();

  /// 交易对名称，如：BTC/USD
  TextColumn get pairName => text()();

  /// 基础资产名称，如：BTC
  TextColumn get baseAssetName => text()();

  /// 报价资产名称，如：USD
  TextColumn get quoteAssetName => text()();

  /// 图标URL
  TextColumn get iconUrl => text()();

  /// 类型，如：Crypto
  TextColumn get type => text()();

  /// 是否激活
  BoolColumn get isActive => boolean()();

  /// 时间戳
  IntColumn get timestamp => integer()();

  /// 交易时间表
  TextColumn get tradingSchedule =>
      text().nullable().map(TradingScheduleConverter())();

  /// 保留几位小数
  IntColumn get pipSize => integer()();

  /// 最小杠杆倍数
  IntColumn get leverageMin => integer()();

  /// 最大杠杆倍数
  IntColumn get leverageMax => integer()();

  /// 是否是是置顶
  BoolColumn get isPinned => boolean()();

  @override
  Set<Column> get primaryKey => {feedId};
}
