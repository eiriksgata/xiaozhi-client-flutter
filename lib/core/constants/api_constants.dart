/// API 常量
class ApiConstants {
  ApiConstants._();

  // 基础 URL（从配置中获取）
  static String baseUrl = 'https://api.example.com';

  // API 端点
  static const String chat = '/api/chat';
  static const String agents = '/api/agents';
  static const String upload = '/api/upload';
  static const String stream = '/api/stream';

  // Header Keys
  static const String authorization = 'Authorization';
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';

  // Content Types
  static const String applicationJson = 'application/json';
  static const String multipartFormData = 'multipart/form-data';
}
