class CancelError extends Error {
  final String message;

  CancelError({this.message = "Actively cancel"});

  @override
  String toString() => "Task canceled: $message";
}
