import 'package:dio/dio.dart';
import 'package:finality/data/network/model/manic/challenge_response.dart';
import 'package:finality/data/network/model/manic/check_user_request.dart';
import 'package:finality/data/network/model/manic/check_user_response.dart';
import 'package:finality/data/network/model/manic/sign_in_request.dart';
import 'package:finality/data/network/model/manic/sign_in_response.dart';
import 'package:retrofit/retrofit.dart';

import 'model/manic/check_invite_code_request.dart';
import 'model/manic/check_invite_code_response.dart';

part 'manic_auth_service.g.dart';

@RestApi()
abstract class ManicAuthService {
  factory ManicAuthService(
    Dio dio, {
    String? baseUrl,
  }) =>
      _ManicAuthService(dio,
          baseUrl: baseUrl ?? 'https://bo-server-api-stg.manic.trade');

  /// 1. 白名单验证
  @POST('/users/check')
  Future<CheckUserResponse> checkUser(@Body() CheckUserRequest request);

  /// 2. 获取登录 challenge（含 nonce）
  @GET('/users/challenge')
  Future<ChallengeResponse> getChallenge(@Query('wallet') String wallet);

  /// 3. Sign in - 使用钱包签名登录
  @POST('/users/sign-in')
  Future<SignInResponse> signIn(@Body() SignInRequest request);

  /// 3. Check invite code
  @POST('/users/check-invite-code')
  Future<CheckInviteCodeResponse> checkInviteCode(
      @Body() CheckInviteCodeRequest request);
}
