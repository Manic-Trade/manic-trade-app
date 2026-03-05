import 'dart:async';
import 'package:dio/dio.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/data/network/solana_rpc_service.dart';
import 'package:finality/features/assets/transfer/execute_status.dart';
import 'package:solana/solana.dart';

class TransactionStatusPoller {
  final SolanaRpcService solanaRpcService;
  final Duration pollInterval;
  final Duration maxPollDuration;
  final String txId;

  bool _isPolling = false;
  CancelToken? _pollTransactionCancelToken;

  TransactionStatusPoller({
    required this.solanaRpcService,
    required this.txId,
    this.pollInterval = const Duration(seconds: 3),
    this.maxPollDuration = const Duration(seconds: 18),
  });

  void _cleanupResources() {
    _isPolling = false;
    _pollTransactionCancelToken?.cancel();
    _pollTransactionCancelToken = null;
  }

  Future<ExecuteStatus?> pollUntilComplete() async {
    if (_isPolling) {
      return null;
    }
    final endTime = DateTime.now().add(maxPollDuration);
    _isPolling = true;
    ExecuteStatus currentStatus = ExecuteStatus.pending;

    while (_isPolling && DateTime.now().isBefore(endTime)) {
      try {
        _pollTransactionCancelToken = CancelToken();
        final statusResponse = await solanaRpcService.getSignatureStatus(
          txId,
        );

        if (!_isPolling) break;
        if (statusResponse == null) {
          currentStatus = ExecuteStatus.failed;
          break;
        }
        if (statusResponse.confirmationStatus==Commitment.confirmed) {
          currentStatus = ExecuteStatus.success;
          break;
        } else if (statusResponse.err!=null) {
          currentStatus = ExecuteStatus.failed;
          break;
        }

        await Future.delayed(pollInterval);
      } catch (e) {
        if (e is DioException && e.type == DioExceptionType.cancel) {
          break;
        }
        logger.e('pollTransactionStatus error: $e');
        currentStatus = ExecuteStatus.failed;
        break;
      }
    }
    // 处理轮询超时情况
    if (_isPolling && currentStatus == ExecuteStatus.pending) {
      currentStatus = ExecuteStatus.timeout;
    }

    return currentStatus == ExecuteStatus.pending ? null : currentStatus;
  }

  void cancel() {
    _isPolling = false;
    _cleanupResources();
  }

  bool get isPolling => _isPolling;
}
