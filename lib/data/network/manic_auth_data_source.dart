import 'package:finality/data/network/manic_auth_service.dart';
import 'package:finality/data/network/model/manic/challenge_response.dart';
import 'package:finality/data/network/model/manic/check_invite_code_request.dart';
import 'package:finality/data/network/model/manic/check_user_request.dart';
import 'package:finality/data/network/model/manic/check_user_response.dart';
import 'package:finality/data/network/model/manic/sign_in_request.dart';
import 'package:finality/data/network/model/manic/sign_in_response.dart';

import 'model/manic/check_invite_code_response.dart';

class ManicAuthDataSource {
  final ManicAuthService _authService;

  ManicAuthDataSource(this._authService);

  /// 获取登录 challenge（含 nonce）
  Future<ChallengeResponse> getChallenge(String wallet) {
    return _authService.getChallenge(wallet);
  }

  Future<SignInResponse> signIn({
    required String address,
    required String message,
    required String signedMessage,
  }) {
    return _authService.signIn(SignInRequest(
        message: message, signedMessage: signedMessage, address: address));
  }

  Future<CheckUserResponse> checkUser(CheckUserRequest request) {
    return _authService.checkUser(request);
  }

  Future<CheckInviteCodeResponse> checkInviteCode(String inviteCode) {
    return _authService
        .checkInviteCode(CheckInviteCodeRequest(inviteCode: inviteCode));
  }
}
