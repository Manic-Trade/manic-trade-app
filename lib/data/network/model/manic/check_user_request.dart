class CheckUserRequest {
  final String userId;
  final String orgId;
  final String name;
  final String walletSolana;
  final String walletEvm;
  final String oauth; // "wallet", "email", "google"
  final String? email;
  final String? wallet;
  final String inviteCode;

  const CheckUserRequest({
    required this.userId,
    required this.orgId,
    required this.name,
    required this.walletSolana,
    required this.walletEvm,
    required this.oauth,
    required this.inviteCode,
     this.email,
     this.wallet,
  });

  // wallet login
  factory CheckUserRequest.wallet({
    required String userId,
    required String orgId,
    required String name,
    required String walletSolana,
    required String walletEvm,
    required String wallet,
    required String inviteCode,
  }) {
    return CheckUserRequest(
      userId: userId,
      orgId: orgId,
      name: name,
      walletSolana: walletSolana,
      walletEvm: walletEvm,
      oauth: "wallet",
      wallet: wallet,
      inviteCode: inviteCode,
    );
  }

  // google login
  factory CheckUserRequest.google({
    required String userId,
    required String orgId,
    required String name,
    required String walletSolana,
    required String walletEvm,
    required String email,
    required String inviteCode,
  }) {
    return CheckUserRequest(
      userId: userId,
      orgId: orgId,
      name: name,
      walletSolana: walletSolana,
      walletEvm: walletEvm,
      oauth: "google",
      email: email,
      inviteCode: inviteCode,
    );
  }

  // email login
  factory CheckUserRequest.email({
    required String userId,
    required String orgId,
    required String name,
    required String walletSolana,
    required String walletEvm,
    required String email,
    required String inviteCode,
  }) {
    return CheckUserRequest(
      userId: userId,
      orgId: orgId,
      name: name,
      walletSolana: walletSolana,
      walletEvm: walletEvm,
      oauth: "email",
      email: email,
      inviteCode: inviteCode,
    );
  }

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "org_id": orgId,
        "name": name,
        "wallet_solana": walletSolana,
        "wallet_evm": walletEvm,
        "oauth": oauth,
        "email": email??"",
        "wallet": wallet??"",
        "invite_code": inviteCode,
      };
}