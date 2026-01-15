/// API 统一响应模型
/// 作者: 罗耀生

class ApiResult<T> {
  final int? code;
  final String? message;
  final T? data;

  ApiResult({
    this.code,
    this.message,
    this.data,
  });

  factory ApiResult.fromJson(Map<String, dynamic> json, T? Function(dynamic)? fromJsonT) {
    return ApiResult<T>(
      code: json['code'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }

  bool get isSuccess => code != null && code! >= 200 && code! < 300;

  @override
  String toString() => 'ApiResult{code: $code, message: $message, data: $data}';
}
