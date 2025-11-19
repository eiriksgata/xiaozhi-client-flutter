import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // 用于使用 utf8.encode

class XiaozhiDeviceInfoUtil {
  //单例模式
  XiaozhiDeviceInfoUtil._privateConstructor();
  static final XiaozhiDeviceInfoUtil _instance =
      XiaozhiDeviceInfoUtil._privateConstructor();
  static XiaozhiDeviceInfoUtil get instance => _instance;

  getDeviceClientId() {
    return 'flutter_client_123456';
  }

  /// 获取设备型号
  static Future<String> getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.manufacturer} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.model;
    } else {
      return 'Unknown';
    }
  }

  //模拟一个MAC地址
  getDeviceMacAddress() {
    //md5随机生成一个MAC地址
    final deviceInfo = DeviceInfoPlugin();
    final hashCode = deviceInfo.deviceInfo.hashCode;
    // 1. 将字符串编码为UTF-8字节
    List<int> bytes = utf8.encode(hashCode.toString());

    // 2. 计算MD5哈希值 b92e7e92f1884a0c070385ff451c8dc2
    Digest digest = md5.convert(bytes);
  
    // 3. 将结果转换为十六进制字符串
    String md5Result = digest.toString();

    print(md5Result); // 输出：e68d3d......
  }
}
