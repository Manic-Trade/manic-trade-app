// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_history_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PositionHistoryItem _$PositionHistoryItemFromJson(Map<String, dynamic> json) =>
    PositionHistoryItem(
      positionId: json['position_id'] as String,
      asset: json['asset'] as String,
      mode: json['mode'] as String?,
      amount: (json['amount'] as num).toInt(),
      uiAmount: (json['ui_amount'] as num).toDouble(),
      boundaryPrice: (json['boundary_price'] as num).toDouble(),
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      side: json['side'] as String,
      payout: (json['payout'] as num).toInt(),
      status: json['status'] as String,
      result: json['result'] as String?,
      openSig: json['open_sig'] as String?,
      resultSig: json['result_sig'] as String?,
      startTime: (json['start_time'] as num).toInt(),
      endTime: (json['end_time'] as num).toInt(),
      profit: (json['profit'] as num?)?.toInt(),
      profitPercent: (json['profitPercent'] as num?)?.toInt(),
      premiumAmount: (json['premiumAmount'] as num?)?.toInt(),
      createdAt: (json['created_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PositionHistoryItemToJson(
        PositionHistoryItem instance) =>
    <String, dynamic>{
      'position_id': instance.positionId,
      'asset': instance.asset,
      'mode': instance.mode,
      'amount': instance.amount,
      'ui_amount': instance.uiAmount,
      'boundary_price': instance.boundaryPrice,
      'final_price': instance.finalPrice,
      'side': instance.side,
      'payout': instance.payout,
      'status': instance.status,
      'result': instance.result,
      'open_sig': instance.openSig,
      'result_sig': instance.resultSig,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'profit': instance.profit,
      'profitPercent': instance.profitPercent,
      'premiumAmount': instance.premiumAmount,
      'created_at': instance.createdAt,
    };
