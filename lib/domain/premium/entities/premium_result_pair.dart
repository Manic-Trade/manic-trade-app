import 'package:finality/domain/premium/entities/premium_input.dart';
import 'package:finality/domain/premium/entities/premium_result.dart';

/// Premium 计算结果（包含 Higher 和 Lower 两个方向，以及计算时的输入参数）
class PremiumResultPair {
  /// Higher（看涨）的计算结果
  final PremiumResult higher;

  /// Lower（看跌）的计算结果
  final PremiumResult lower;

  /// 计算时的输入参数
  final PremiumInput? input;

  const PremiumResultPair({
    required this.higher,
    required this.lower,
    required this.input,
  });

  static const zero = PremiumResultPair(
    higher: PremiumResult.zero,
    lower: PremiumResult.zero,
    input: null,
  );

  /// 是否为有效值
  bool get isValid => higher.isValid && lower.isValid;
}
