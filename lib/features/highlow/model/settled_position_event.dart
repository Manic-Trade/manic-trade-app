import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/data/socket/game_status_socket_client.dart';
import 'package:finality/domain/options/entities/opened_position.dart';

/// 结算事件数据类，用于外部监听和展示 UI
class SettledPositionEvent {
  SettledPositionEvent({
    required this.position,
    required this.event,
    required this.notificationtimestamp,
  });

  final OpenedPosition position;
  final PositionEvent event;
  final int notificationtimestamp;

  String get pnl {
    if (event.isWin) {
      return position.winPayoutDisplay;
    } else if (event.isClosed) {
      var payoutLamports = event.payout ?? 0;
      var payout = payoutLamports / 1000000;
      var payoutDisplay = payout.formatWithDecimals(2);
      return payoutDisplay;
    } else {
      return position.lossPayoutDisplay;
    }
  }
}
