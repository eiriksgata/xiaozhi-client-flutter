import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 语音波形可视化组件
/// 显示基于音频振幅的动态波形条
class VoiceWaveVisualizer extends StatefulWidget {
  /// 是否正在录音
  final bool isRecording;

  /// 振幅流 (0.0 ~ 1.0)
  final Stream<double> amplitudeStream;

  /// 波形条数量
  final int barCount;

  /// 组件宽度
  final double width;

  /// 组件高度
  final double height;

  /// 波形条颜色
  final Color? activeColor;

  /// 是否处于取消状态
  final bool isCancelling;

  const VoiceWaveVisualizer({
    super.key,
    required this.isRecording,
    required this.amplitudeStream,
    this.barCount = 5,
    this.width = 60,
    this.height = 28,
    this.activeColor,
    this.isCancelling = false,
  });

  @override
  State<VoiceWaveVisualizer> createState() => _VoiceWaveVisualizerState();
}

class _VoiceWaveVisualizerState extends State<VoiceWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  StreamSubscription<double>? _amplitudeSubscription;

  // 保存每个波形条的目标高度比例
  late List<double> _barHeights;
  // 随机偏移，让波形更自然
  late List<double> _randomOffsets;

  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _barHeights = List.filled(widget.barCount, 0.2);
    _randomOffsets = List.generate(
      widget.barCount,
      (_) => _random.nextDouble() * 0.3,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
        setState(() {});
      });

    if (widget.isRecording) {
      _startListening();
    }
  }

  @override
  void didUpdateWidget(VoiceWaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRecording && !oldWidget.isRecording) {
      _startListening();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _stopListening();
    }
  }

  void _startListening() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = widget.amplitudeStream.listen((amplitude) {
      if (!mounted) return;

      // 更新波形条高度，添加随机变化让效果更自然
      setState(() {
        for (int i = 0; i < widget.barCount; i++) {
          // 基础高度 + 振幅影响 + 随机偏移
          final baseHeight = 0.15;
          final amplitudeEffect = amplitude * 0.7;
          final randomEffect = _random.nextDouble() * 0.15 * amplitude;

          _barHeights[i] = (baseHeight +
                  amplitudeEffect +
                  randomEffect +
                  _randomOffsets[i] * amplitude)
              .clamp(0.1, 1.0);
        }
      });

      // 触发动画
      if (!_animationController.isAnimating) {
        _animationController.forward(from: 0);
      }
    });
  }

  void _stopListening() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;

    // 重置波形条高度
    setState(() {
      _barHeights = List.filled(widget.barCount, 0.2);
    });
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 根据状态选择颜色
    Color barColor;
    if (widget.isCancelling) {
      barColor = isDark ? Colors.red[300]! : Colors.red[700]!;
    } else if (widget.activeColor != null) {
      barColor = widget.activeColor!;
    } else {
      barColor = isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6750A4);
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(widget.barCount, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            width: 4,
            height: widget.isRecording
                ? widget.height * _barHeights[index]
                : widget.height * 0.2,
            decoration: BoxDecoration(
              color: widget.isRecording
                  ? barColor
                  : (isDark ? Colors.grey[600] : Colors.grey[400]),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
