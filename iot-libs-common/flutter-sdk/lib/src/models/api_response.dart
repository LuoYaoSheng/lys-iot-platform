/// API 响应模型
/// 作者: 罗耀生
/// 日期: 2025-12-14

class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  const ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  bool get isSuccess => code == 200 || code == 201;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T?)? toJsonT) {
    return {
      'code': code,
      'message': message,
      if (data != null) 'data': toJsonT != null ? toJsonT(data) : data,
    };
  }

  @override
  String toString() => 'ApiResponse(code: $code, message: $message, data: $data)';
}

/// 分页响应
class PagedResponse<T> {
  final List<T> list;
  final int total;
  final int page;
  final int size;

  const PagedResponse({
    required this.list,
    required this.total,
    required this.page,
    required this.size,
  });

  int get totalPages => (total / size).ceil();
  bool get hasMore => page < totalPages;

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResponse<T>(
      list: (json['list'] as List).map((e) => fromJsonT(e)).toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      size: json['size'] as int,
    );
  }
}
