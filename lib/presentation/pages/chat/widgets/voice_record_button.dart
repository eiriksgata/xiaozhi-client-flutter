import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:xiaozhi_client_flutter/core/utils/audio_util.dart';
import 'voice_wave_visualizer.dart';

/// 按住说话按钮组件
class VoiceRecordButton extends StatefulWidget {
  final Function() onRecordStart;
  final Function() onRecordEnd;
  final Function() onRecordCancel;
  final Function(Uint8List) onAudioSend;

  /// 持续监听模式回调
  final Function()? onContinuousListenStart;
  final Function()? onContinuousListenStop;

  const VoiceRecordButton({
    super.key,
    required this.onRecordStart,
    required this.onRecordEnd,
    required this.onRecordCancel,
    required this.onAudioSend,
    this.onContinuousListenStart,
    this.onContinuousListenStop,
  });

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton> {
  bool _isRecording = false;
  bool _isCancelling = false;
  bool _isContinuousListening = false; // 持续监听模式

  StreamSubscription<Uint8List>? _audioStreamSubscription; // 音频流订阅

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 根据状态选择文字颜色
    Color textColor;
    if (_isRecording || _isContinuousListening) {
      if (_isCancelling) {
        textColor = isDark ? Colors.red[300]! : Colors.red[700]!;
      } else {
        textColor = isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6750A4);
      }
    } else {
      textColor = isDark ? Colors.grey[300]! : Colors.grey[700]!;
    }

    return Row(
      children: [
        // 🔥 按住说话按钮
        Expanded(
          child: GestureDetector(
            onLongPressStart: _isContinuousListening ? null : _onLongPressStart,
            onLongPressEnd: _isContinuousListening ? null : _onLongPressEnd,
            onLongPressMoveUpdate: _isContinuousListening
                ? null
                : _onLongPressMoveUpdate,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: (_isRecording || _isContinuousListening)
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
                    // 🔥 录音时显示波形，否则显示麦克风图标
                    if (_isRecording || _isContinuousListening)
                      VoiceWaveVisualizer(
                        isRecording: _isRecording || _isContinuousListening,
                        amplitudeStream: AudioUtil.amplitudeStream,
                        isCancelling: _isCancelling,
                        barCount: 5,
                        width: 50,
                        height: 24,
                      )
                    else
                      Icon(Icons.mic_none, size: 20, color: textColor),
                    const SizedBox(width: 8),
                    Text(
                      _isContinuousListening
                          ? '正在聆听...'
                          : (_isRecording
                                ? (_isCancelling ? '松开取消' : '松开发送')
                                : '按住说话'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 🔥 持续监听按钮
        _buildContinuousListenButton(isDark),
      ],
    );
  }

  /// 构建持续监听按钮
  Widget _buildContinuousListenButton(bool isDark) {
    return GestureDetector(
      onTap: _toggleContinuousListen,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _isContinuousListening
              ? (isDark ? Colors.red[700] : Colors.red[400])
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          shape: BoxShape.circle,
          boxShadow: _isContinuousListening
              ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          _isContinuousListening ? Icons.stop : Icons.fiber_manual_record,
          size: 24,
          color: _isContinuousListening
              ? Colors.white
              : (isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      ),
    );
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isCancelling = false;
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
    });
  }

  // 监听手指滑动，判断是否取消
  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    // 向上滑动超过 100 像素则标记为取消，但不停止录音
    final distance = details.localPosition.dy;
    setState(() {
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
            widget.onAudioSend(audioData);
          }
        },
        onError: (error) {
          print('音频流错误: $error');
          setState(() {
            _isRecording = false;
          });
        },
      );

      // 开始录音
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

      print('停止录音完成');
    } catch (e) {
      print('停止录音失败: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  /// 切换持续监听模式
  Future<void> _toggleContinuousListen() async {
    if (_isContinuousListening) {
      await _stopContinuousListening();
    } else {
      await _startContinuousListening();
    }
  }

  /// 开始持续监听
  Future<void> _startContinuousListening() async {
    try {
      setState(() {
        _isContinuousListening = true;
      });

      // 震动反馈
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 30);
      }

      // 1. 通知 chat_page 开始持续监听
      widget.onContinuousListenStart?.call();

      // 2. 订阅音频流
      _audioStreamSubscription = AudioUtil.audioStream.listen(
        (audioData) {
          if (_isContinuousListening) {
            widget.onAudioSend(audioData);
          }
        },
        onError: (error) {
          print('持续监听音频流错误: $error');
          _stopContinuousListening();
        },
      );

      // 3. 开始录音（启用 AEC 回声消除）
      await AudioUtil.startRecording(enableAEC: true);

      print('开始持续监听模式（已启用 AEC 回声消除）');
    } catch (e) {
      print('启动持续监听失败: $e');
      setState(() {
        _isContinuousListening = false;
      });
      _showError('启动持续监听失败: $e');
    }
  }

  /// 停止持续监听
  Future<void> _stopContinuousListening() async {
    if (!_isContinuousListening) return;

    try {
      // 震动反馈
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 20);
      }

      // 1. 取消音频流订阅
      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;

      // 2. 停止录音
      await AudioUtil.stopRecording();

      // 3. 通知 chat_page 停止持续监听
      widget.onContinuousListenStop?.call();

      setState(() {
        _isContinuousListening = false;
      });

      print('停止持续监听模式');
    } catch (e) {
      print('停止持续监听失败: $e');
      setState(() {
        _isContinuousListening = false;
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
