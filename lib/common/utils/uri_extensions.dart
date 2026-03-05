extension UriExtensions on Uri {
  Uri addQueryParameters(Map<String, String> queryParameters) {
    var parameters = <String, String>{};
    parameters.addAll(this.queryParameters);
    parameters.addAll(queryParameters);
    return replace(queryParameters: queryParameters);
  }
}
