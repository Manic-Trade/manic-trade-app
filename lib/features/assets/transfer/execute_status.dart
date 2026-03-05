enum ExecuteStatus {
  building,
  buildFailure,
  pending,
  timeout,
  success,
  failed;

  bool get isLoading => this == building || this == pending;
}
