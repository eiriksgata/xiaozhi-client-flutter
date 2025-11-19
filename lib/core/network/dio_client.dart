import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import 'api_interceptor.dart';

/// Dio 客户端封装
class DioClient {
  DioClient._();

  static final Logger _logger = Logger();
  static Dio? _dio;

  /// 获取 Dio 实例
  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  /// 创建 Dio 实例
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          ApiConstants.contentType: ApiConstants.applicationJson,
          ApiConstants.accept: ApiConstants.applicationJson,
        },
      ),
    );

    // 添加拦截器
    dio.interceptors.addAll([
      ApiInterceptor(),
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => _logger.d(obj),
      ),
    ]);

    return dio;
  }

  /// 更新 Base URL
  static void updateBaseUrl(String baseUrl) {
    ApiConstants.baseUrl = baseUrl;
    _dio?.options.baseUrl = baseUrl;
  }

  /// 更新 Token
  static void updateToken(String token) {
    _dio?.options.headers[ApiConstants.authorization] = 'Bearer $token';
  }

  /// 清除 Token
  static void clearToken() {
    _dio?.options.headers.remove(ApiConstants.authorization);
  }

  /// 重置 Dio 实例
  static void reset() {
    _dio = null;
  }
}
