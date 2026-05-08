import 'package:equatable/equatable.dart';
import 'package:finality/domain/wallet/entities/unified_account.dart';

import '../../../data/drift/entities/network.dart';

class AccountNetwork extends Equatable {
  final UnifiedAccount account;
  final Network network;

  const AccountNetwork(this.account, this.network);

  @override
  List<Object> get props => [account, network];
}
