import 'package:equatable/equatable.dart';

  class HoldingRequest extends Equatable {
  final String contractAddress;
  final String networkCode;
  final String holderAddress;

  const HoldingRequest({
    required this.contractAddress,
    required this.networkCode,
    required this.holderAddress,
  });

  @override
  List<Object> get props =>
      [contractAddress, networkCode, holderAddress];
}
