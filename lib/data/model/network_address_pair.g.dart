// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_address_pair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkAddressPair _$NetworkAddressPairFromJson(Map<String, dynamic> json) =>
    NetworkAddressPair(
      json['networkCode'] as String,
      json['address'] as String,
    );

Map<String, dynamic> _$NetworkAddressPairToJson(NetworkAddressPair instance) =>
    <String, dynamic>{
      'networkCode': instance.networkCode,
      'address': instance.address,
    };
