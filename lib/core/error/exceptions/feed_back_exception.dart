class FeedBackException implements Exception {
  final String message;

  FeedBackException({required this.message});

  @override
  String toString() => message;
}