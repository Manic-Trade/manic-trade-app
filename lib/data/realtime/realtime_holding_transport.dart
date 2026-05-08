import 'dart:async';
import 'dart:collection';

import 'package:finality/core/logger.dart';
import 'package:finality/data/drift/entities/token_holding.dart';
import 'package:finality/data/realtime/model/holding_request.dart';
import 'package:finality/data/repository/holdings_data_repository.dart';
import 'package:rxdart/rxdart.dart';


class RealtimeHoldingTransport {
  final HoldingsDataRepository _repository;
  final Map<HoldingRequest, BehaviorSubject<TokenHolding>> _balanceSubjects;

  RealtimeHoldingTransport(this._repository)
      : _balanceSubjects =
            HashMap<HoldingRequest, BehaviorSubject<TokenHolding>>();

  StreamSubscription? _tokenAssetsSubscription;

  void _startListeningToUpdates() {
    _tokenAssetsSubscription ??=
        _repository.tokenHoldingsUpdateStream.listen((tokenHoldings) {
      dispatchHoldings(tokenHoldings);
    });
  }

  void _stopListeningToUpdates() {
    _tokenAssetsSubscription?.cancel();
    _tokenAssetsSubscription = null;
  }

  void dispatchHoldings(List<TokenHolding> holdings) async {
    //映射
    final holdingsMap = Map.fromEntries(holdings.map((holding) => MapEntry(
        HoldingRequest(
            contractAddress: holding.contractAddress,
            networkCode: holding.networkCode,
            holderAddress: holding.holderAddress,),
        holding)));

    // 更新现有的 subjects
    for (final entry in _balanceSubjects.entries) {
      if (holdingsMap.isEmpty) {
        break;
      }
      final subject = entry.value;
      var currentHolding = subject.valueOrNull;
      var holding = holdingsMap.remove(entry.key);
      if (holding != null) {
        if (holding.isNewer(currentHolding)) {
          subject.add(holding);
        }
      }
    }

    // 添加新的 holdings
    if (holdingsMap.isNotEmpty) {
      holdingsMap.forEach((key, value) {
        _balanceSubjects[key] = BehaviorSubject<TokenHolding>()..add(value);
      });
    }
  }

  void loadHolding(HoldingRequest request, bool refresh) async {
    var balanceFromLocal = await _repository.loadTokenHoldingFromLocal(
        request.contractAddress, request.networkCode, request.holderAddress);
    var subject = _balanceSubjects.putIfAbsent(
        request, () => BehaviorSubject<TokenHolding>());
    if (balanceFromLocal != null) {
      subject.add(balanceFromLocal);
    } else {
      subject.add(_createDefaultHolding(request));
    }
    if (refresh) {
      await refreshHolding(request);
    }
  }

  TokenHolding _createDefaultHolding(HoldingRequest request) {
    return TokenHolding(
        contractAddress: request.contractAddress,
        networkCode: request.networkCode,
        holderAddress: request.holderAddress,
        balance: "0");
  }


  Future<void> refreshHolding(HoldingRequest request) async {
    try {
      var balanceFromRemote = await _repository.fetchTokenHoldingPrice(
          request.contractAddress, request.networkCode, request.holderAddress);
      var subject = _balanceSubjects.putIfAbsent(
          request, () => BehaviorSubject<TokenHolding>());
      subject.add(balanceFromRemote.holding);
    } catch (error) {
      logger.e("Refresh balance $request", error: error);
    }
  }

  void cleanUnusedSubjects() {
    _balanceSubjects.removeWhere((request, subject) {
      if (!subject.hasListener) {
        if (!subject.isClosed) {
          subject.close();
        }
        return true;
      }
      return false;
    });
    if (_balanceSubjects.isEmpty) {
      _stopListeningToUpdates();
    }
  }

  void cleanAllSubjects() {
    _balanceSubjects.removeWhere((request, subject) {
      if (!subject.isClosed) {
        subject.close();
      }
      return true;
    });
    _stopListeningToUpdates();
  }

  Stream<TokenHolding> subscribeHolding(HoldingRequest request,
      {bool refresh = false}) {
    final subject = _balanceSubjects.putIfAbsent(request, () {
      final subject = BehaviorSubject<TokenHolding>();
      loadHolding(request, refresh);
      return subject;
    });

    if (refresh) {
      loadHolding(request, true);
    }
    _startListeningToUpdates();
    return subject.stream;
  }
}
