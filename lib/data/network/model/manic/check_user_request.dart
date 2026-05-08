import 'package:finality/env/app_secrets.dart';

class CheckUserRequest {
  final String userId;
  // Turnkey 用户的 sub-organization id（来自 turnkeyManager.session.organizationId）。
  // 字段名沿用历史命名，序列化时写入 `sub_org_id`；payload 里的 `org_id` 取自
  // 环境变量里的父 org id，与 web 端保持一致。
  final String orgId;
  final String name;
  final String walletSolana;
  final String walletEvm;
  final String oauth; // "wallet", "email", "google"
  final String? email;
  final String? wallet;
  final String? inviteCode;
  // X 登录：Turnkey oauthProvider.subject（X 数字 user id），后端据此反查真 @handle
  final String? socialId;
  // X 登录：兜底名字，后端首选会用 Twitter API 查到的真 username
  final String? socialName;

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
    this.socialId,
    this.socialName,
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

  // apple login
  factory CheckUserRequest.apple({
    required String userId,
    required String orgId,
    required String name,
    required String walletSolana,
    required String walletEvm,
    required String inviteCode,
    String? email,
  }) {
    return CheckUserRequest(
      userId: userId,
      orgId: orgId,
      name: name,
      walletSolana: walletSolana,
      walletEvm: walletEvm,
      oauth: "apple",
      email: email,
      inviteCode: inviteCode,
    );
  }

  // x login
  factory CheckUserRequest.x({
    required String userId,
    required String orgId,
    required String name,
    required String walletSolana,
    required String walletEvm,
    String? inviteCode,
    String? socialId,
    String? socialName,
  }) {
    return CheckUserRequest(
      userId: userId,
      orgId: orgId,
      name: name,
      walletSolana: walletSolana,
      walletEvm: walletEvm,
      oauth: "x",
      inviteCode: inviteCode,
      socialId: socialId,
      socialName: socialName,
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

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      "user_id": userId,
      "org_id": AppSecrets.turnkeyOrganizationId,
      "sub_org_id": orgId,
      "name": name,
      "wallet_solana": walletSolana,
      "wallet_evm": walletEvm,
      "oauth": oauth,
      "email": email ?? "",
      "wallet": wallet ?? "",
      "invite_code": inviteCode ?? "",
    };
    if (socialId != null && socialId!.isNotEmpty) {
      json["social_id"] = socialId;
    }
    if (socialName != null && socialName!.isNotEmpty) {
      json["social_name"] = socialName;
    }
    return json;
  }
}
