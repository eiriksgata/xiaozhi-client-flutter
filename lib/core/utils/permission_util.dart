import 'package:permission_handler/permission_handler.dart';

/// 权限工具类
class PermissionUtil {
  PermissionUtil._();

  /// 请求相机权限
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// 请求麦克风权限
  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// 请求存储权限
  static Future<bool> requestStorage() async {
    if (await Permission.storage.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// 请求照片权限（iOS/Android 13+）
  static Future<bool> requestPhotos() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// 请求多个权限
  static Future<Map<Permission, PermissionStatus>> requestMultiple(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// 检查相机权限
  static Future<bool> checkCamera() async {
    return await Permission.camera.isGranted;
  }

  /// 检查麦克风权限
  static Future<bool> checkMicrophone() async {
    return await Permission.microphone.isGranted;
  }

  /// 检查存储权限
  static Future<bool> checkStorage() async {
    return await Permission.storage.isGranted;
  }

  /// 打开应用设置
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// 请求所有必需权限
  static Future<bool> requestAllRequired() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }
}
