import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

/// Toast 工具类
class ToastUtil {
  ToastUtil._();

  /// 显示普通提示
  static void show(
    String message, {
    Toast length = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: gravity,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  /// 显示成功提示
  static void success(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  /// 显示错误提示
  static void error(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFFF44336),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  /// 显示警告提示
  static void warning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFFFF9800),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  /// 取消所有 Toast
  static void cancel() {
    Fluttertoast.cancel();
  }
}
