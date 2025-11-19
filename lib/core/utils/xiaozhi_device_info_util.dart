import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// 设备信息工具类
class XiaozhiDeviceInfoUtil {
  // 单例模式
  XiaozhiDeviceInfoUtil._privateConstructor();
  static final XiaozhiDeviceInfoUtil _instance =
      XiaozhiDeviceInfoUtil._privateConstructor();
  static XiaozhiDeviceInfoUtil get instance => _instance;

  static const String _keyDeviceId = 'device_unique_id';
  static const String _keyMacAddress = 'device_mac_address';
  static const String _keyClientId = 'device_client_id';

  /// 获取设备唯一标识（推荐方案）
  ///
  /// 策略：
  /// 1. 优先从本地读取已保存的 UUID
  /// 2. 如果不存在，基于设备信息生成稳定的标识
  /// 3. 保存到本地，确保卸载重装后仍然一致
  Future<String> getDeviceUniqueId() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. 尝试读取已保存的设备ID
    String? savedId = prefs.getString(_keyDeviceId);
    if (savedId != null && savedId.isNotEmpty) {
      return savedId;
    }

    // 2. 生成新的设备ID
    String deviceId = await _generateDeviceId();

    // 3. 保存到本地
    await prefs.setString(_keyDeviceId, deviceId);

    return deviceId;
  }

  /// 生成设备ID
  ///
  /// 方案：基于设备硬件信息生成 MD5 哈希
  /// Android: androidId (设备唯一标识，恢复出厂设置会重置)
  /// iOS: identifierForVendor (同一厂商的应用共享，卸载重装会变化)
  Future<String> _generateDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String identifier = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Android ID: 在大多数设备上稳定，但恢复出厂设置会重置
        identifier = androidInfo.id;

        // 备用方案：组合多个信息
        if (identifier.isEmpty) {
          identifier =
              '${androidInfo.board}-${androidInfo.brand}-'
              '${androidInfo.device}-${androidInfo.hardware}';
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // identifierForVendor: 同一厂商应用共享
        identifier = iosInfo.identifierForVendor ?? '';

        // 备用方案
        if (identifier.isEmpty) {
          identifier =
              '${iosInfo.name}-${iosInfo.systemVersion}-'
              '${iosInfo.model}';
        }
      } else {
        // 其他平台：生成随机 UUID
        identifier = const Uuid().v4();
      }

      // 如果仍然为空，生成随机 UUID
      if (identifier.isEmpty) {
        identifier = const Uuid().v4();
      }

      // 计算 MD5 哈希，统一格式
      final bytes = utf8.encode(identifier);
      final digest = md5.convert(bytes);
      return digest.toString();
    } catch (e) {
      // 异常情况：生成随机 UUID
      return const Uuid().v4();
    }
  }

  /// 获取设备客户端ID（用于API调用）UUID
  Future<String> getDeviceClientId() async {
    //检查是否存储过客户端ID
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString(_keyClientId);
    if (savedId != null && savedId.isNotEmpty) {
      return savedId;
    }
    final uuid = Uuid().v4();
    await prefs.setString(_keyClientId, uuid);
    return uuid;
  }

  /// 生成模拟 MAC 地址
  Future<String> _generateDeviceMacAddress() async {
    final deviceId = await getDeviceUniqueId();
    // 通过设备ID生成伪MAC地址（仅供展示使用）
    final hash = md5.convert(utf8.encode(deviceId)).bytes;
    return '${hash[0].toRadixString(16).padLeft(2, '0')}:'
        '${hash[1].toRadixString(16).padLeft(2, '0')}:'
        '${hash[2].toRadixString(16).padLeft(2, '0')}:'
        '${hash[3].toRadixString(16).padLeft(2, '0')}:'
        '${hash[4].toRadixString(16).padLeft(2, '0')}:'
        '${hash[5].toRadixString(16).padLeft(2, '0')}';
  }

  Future<String> getDeviceMacAddress() async {
    //检查是否存储过虚拟MAC地址
    final prefs = await SharedPreferences.getInstance();
    String? savedMac = prefs.getString(_keyMacAddress);
    if (savedMac != null && savedMac.isNotEmpty) {
      return savedMac;
    }
    String macAddress = await _generateDeviceMacAddress();
    await prefs.setString(_keyMacAddress, macAddress);
    return macAddress;
  }

  /// 获取设备型号
  Future<String> getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.model;
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// 获取操作系统版本
  Future<String> getOSVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return 'iOS ${iosInfo.systemVersion}';
      } else {
        return Platform.operatingSystem;
      }
    } catch (e) {
      return Platform.operatingSystem;
    }
  }

  /// 获取完整的设备信息（用于调试）
  Future<Map<String, dynamic>> getFullDeviceInfo() async {
    final deviceId = await getDeviceUniqueId();
    final model = await getDeviceModel();
    final osVersion = await getOSVersion();

    return {
      'deviceId': deviceId,
      'model': model,
      'osVersion': osVersion,
      'platform': Platform.operatingSystem,
    };
  }

  /// 重置设备ID（谨慎使用，会生成新的标识）
  Future<void> resetDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDeviceId);
  }
}
