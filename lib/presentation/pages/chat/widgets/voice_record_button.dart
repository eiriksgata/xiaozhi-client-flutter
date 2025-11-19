import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:xiaozhi_client_flutter/core/utils/audio_util.dart';

/// 按住说话按钮组件
class VoiceRecordButton extends StatefulWidget {
  final Function() onRecordStart;
  final Function() onRecordEnd;
  final Function() onRecordCancel;
  final Function(Uint8List) onAudioSend;
  const VoiceRecordButton({
    super.key,
    required this.onRecordStart,
    required this.onRecordEnd,
    required this.onRecordCancel,
    required this.onAudioSend,
  });

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton> {
  bool _isRecording = false;
  bool _isCancelling = false;
  double _dragDistance = 0;

  StreamSubscription<Uint8List>? _audioStreamSubscription; // 音频流订阅
  bool _isVoiceMode = false; // 是否为语音模式

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        decoration: BoxDecoration(
          color: _isRecording
              ? (_isCancelling
                    ? (isDark ? Colors.red[900] : Colors.red[100])
                    : (isDark
                          ? const Color(0xFF4A4458)
                          : const Color(0xFFE8DEF8)))
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                size: 20,
                color: _isRecording
                    ? (_isCancelling
                          ? (isDark ? Colors.red[300] : Colors.red[700])
                          : (isDark
                                ? const Color(0xFFD0BCFF)
                                : const Color(0xFF6750A4)))
                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
              const SizedBox(width: 8),
              Text(
                _isRecording ? (_isCancelling ? '松开取消' : '松开发送') : '按住说话',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _isRecording
                      ? (_isCancelling
                            ? (isDark ? Colors.red[300] : Colors.red[700])
                            : (isDark
                                  ? const Color(0xFFD0BCFF)
                                  : const Color(0xFF6750A4)))
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isCancelling = false;
      _dragDistance = 0;
    });
    _startRecording();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_isCancelling) {
      widget.onRecordCancel();
    } else {
      widget.onRecordEnd();
    }
    _stopRecording();
    setState(() {
      _isCancelling = false;
      _dragDistance = 0;
    });
  }

  // 监听手指滑动，判断是否取消
  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    // 向上滑动超过 100 像素则标记为取消，但不停止录音
    final distance = details.localPosition.dy;
    setState(() {
      _dragDistance = distance;
      _isCancelling = distance < -100;
    });
  }

  // 开始录音（收集数据）
  Future<void> _startRecording() async {
    try {
      setState(() {
        _isRecording = true;
      });

      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 20);
      }

      // 🔥 1. 先通知 chat_screen 准备录音
      widget.onRecordStart.call();

      // 🔥 2. 收集音频流数据，但不立即发送

      _audioStreamSubscription = AudioUtil.audioStream.listen(
        (audioData) {
          if (_isRecording) {
            // 立即发送每个音频数据块
            widget.onAudioSend!(audioData);
            print('立即发送音频数据: ${audioData.length} 字节');
          }
        },
        onError: (error) {
          print('音频流错误: $error');
          setState(() {
            _isRecording = false;
          });
        },
      );
      //开始录音
      await AudioUtil.startRecording();

      print('开始收集录音数据（按住模式）');
    } catch (e) {
      print('录音失败: $e');
      setState(() {
        _isRecording = false;
      });
      _showError('录音失败: $e');
    }
  }

  // 停止录音并合成发送
  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      // 1. 取消音频流订阅
      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;

      // 2. 停止录音
      await AudioUtil.stopRecording();

      setState(() {
        _isRecording = false;
      });

      // 🔥 5. 最后通知 chat_screen 录音结束
      widget.onRecordEnd.call();

      print('停止录音并发送合成数据完成');
    } catch (e) {
      print('停止录音失败: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
