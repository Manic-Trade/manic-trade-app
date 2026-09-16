class TokenId {
  final String contractAddress;
  final String networkCode;

  const TokenId({required this.contractAddress, required this.networkCode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenId &&
          runtimeType == other.runtimeType &&
          contractAddress == other.contractAddress &&
          networkCode == other.networkCode;

  @override
  int get hashCode => contractAddress.hashCode ^ networkCode.hashCode;
}
