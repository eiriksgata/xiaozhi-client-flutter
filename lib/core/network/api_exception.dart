import 'package:dio/dio.dart';

/// API 异常类
class ApiException implements Exception {
  final String message;
  final int? code;
  final dynamic data;

  ApiException({
    required this.message,
    this.code,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: '连接超时，请检查网络连接',
          code: -1,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          message: error.response?.data['message'] ?? '服务器错误',
          code: error.response?.statusCode,
          data: error.response?.data,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: '请求已取消',
          code: -2,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: '网络连接失败，请检查网络设置',
          code: -3,
        );
      default:
        return ApiException(
          message: error.message ?? '未知错误',
          code: -4,
        );
    }
  }

  @override
  String toString() => 'ApiException: $message (code: $code)';
}
