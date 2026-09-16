class SignInRequest {
  final String message;
  final String signedMessage;
  final String address;

  const SignInRequest({
    required this.message,
    required this.signedMessage,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        "signed_message": signedMessage,
        "address": address,
        "message": message,
      };
}
