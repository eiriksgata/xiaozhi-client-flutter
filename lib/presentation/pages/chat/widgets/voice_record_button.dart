import 'package:flutter/material.dart';

/// 按住说话按钮组件
class VoiceRecordButton extends StatefulWidget {
  final VoidCallback onRecordStart;
  final VoidCallback onRecordEnd;
  final VoidCallback onRecordCancel;

  const VoiceRecordButton({
    super.key,
    required this.onRecordStart,
    required this.onRecordEnd,
    required this.onRecordCancel,
  });

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton> {
  bool _isRecording = false;
  bool _isCancelling = false;
  double _dragDistance = 0;

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
                  : (isDark ? const Color(0xFF4A4458) : const Color(0xFFE8DEF8)))
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
                        : (isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6750A4)))
                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
              const SizedBox(width: 8),
              Text(
                _isRecording
                    ? (_isCancelling ? '松开取消' : '松开发送')
                    : '按住说话',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _isRecording
                      ? (_isCancelling
                          ? (isDark ? Colors.red[300] : Colors.red[700])
                          : (isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6750A4)))
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
      _isRecording = true;
      _isCancelling = false;
      _dragDistance = 0;
    });
    widget.onRecordStart();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_isCancelling) {
      widget.onRecordCancel();
    } else {
      widget.onRecordEnd();
    }
    setState(() {
      _isRecording = false;
      _isCancelling = false;
      _dragDistance = 0;
    });
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    // 向上滑动超过 100 像素则取消
    final distance = details.localPosition.dy;
    setState(() {
      _dragDistance = distance;
      _isCancelling = distance < -100;
    });
  }
}
