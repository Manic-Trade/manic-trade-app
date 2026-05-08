

class PagedResponse<T> {
  final int page;
  final int total;
  final List<T> nodes;

  const PagedResponse({
    required this.page,
    required this.total,
    required this.nodes,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return PagedResponse<T>(
      nodes: (json['nodes'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
    );
  }
}

