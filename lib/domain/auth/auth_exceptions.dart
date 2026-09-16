/// 用户未找到异常
/// 当用户尝试登录但在服务器上找不到对应账户时抛出（404 错误）
/// 没有白名单内
class UserNotFoundException implements Exception {
  final String address;
  final String? message;

  UserNotFoundException({
    required this.address,
    this.message,
  });

  @override
  String toString() =>
      'UserNotFoundException: User not found for address: $address${message != null ? ' - $message' : ''}';
}
