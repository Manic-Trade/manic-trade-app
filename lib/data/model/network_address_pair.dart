import 'package:json_annotation/json_annotation.dart';

part 'network_address_pair.g.dart';

@JsonSerializable()
class NetworkAddressPair {
  final String networkCode;
  final String address;

  NetworkAddressPair(this.networkCode, this.address)
      : _networkCodeLowercase = networkCode.toLowerCase(),
        _addressLowercase = address.toLowerCase();

  final String _networkCodeLowercase;
  final String _addressLowercase;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkAddressPair &&
          runtimeType == other.runtimeType &&
          _networkCodeLowercase == other._networkCodeLowercase &&
          _addressLowercase == other._addressLowercase;

  @override
  int get hashCode =>
      _networkCodeLowercase.hashCode ^ _addressLowercase.hashCode;

  factory NetworkAddressPair.fromJson(Map<String, dynamic> json) =>
      _$NetworkAddressPairFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkAddressPairToJson(this);
}
