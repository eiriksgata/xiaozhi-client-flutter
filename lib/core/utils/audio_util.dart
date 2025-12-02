import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:opus_dart/opus_dart.dart';
import 'package:audio_session/audio_session.dart';
import 'package:mp_audio_stream/mp_audio_stream.dart';
import 'package:xiaozhi_client_flutter/app/config/app_config.dart';

/// 音频工具类，用于处理Opus音频编解码和录制播放
class AudioUtil {
  static final _mpAudioStream = getAudioStream();

  static const String TAG = "AudioUtil";

  static final AudioRecorder _audioRecorder = AudioRecorder();
  static bool _isRecorderInitialized = false;
  static bool _isPlayerInitialized = false;
  static bool _isRecording = false;
  static bool _isPlaying = false;

  static final StreamController<Uint8List> _audioStreamController =
      StreamController<Uint8List>.broadcast();

  static Timer? _audioProcessingTimer;

  // 🔥 振幅相关
  static StreamController<double>? _amplitudeStreamController;
  static StreamSubscription<Amplitude>? _amplitudeSubscription;

  // Opus相关
  static final _encoder = SimpleOpusEncoder(
    sampleRate: AppConfig.sampleRate,
    channels: AppConfig.channels,
    application: Application.voip,
  );
  static final _decoder = SimpleOpusDecoder(
    sampleRate: AppConfig.sampleRate,
    channels: AppConfig.channels,
  );

  /// 获取音频流
  static Stream<Uint8List> get audioStream => _audioStreamController.stream;

  /// 🔥 获取归一化振幅流 (0.0 ~ 1.0)
  static Stream<double> get amplitudeStream =>
      _amplitudeStreamController?.stream ?? const Stream.empty();

  /// 初始化音频录制器
  static Future<void> initRecorder() async {
    if (_isRecorderInitialized) return;

    print('$TAG: 开始初始化录音器');

    // 更积极地请求所有可能需要的权限
    if (Platform.isAndroid) {
      print('$TAG: 请求Android所需的所有权限');
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
      ].request();

      print('$TAG: 权限状态:');
      statuses.forEach((permission, status) {
        print('$TAG: $permission: $status');
      });

      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        print('$TAG: 麦克风权限被拒绝');
        throw Exception('需要麦克风权限');
      }
    } else {
      // iOS/其他平台只请求麦克风权限
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print('$TAG: 麦克风权限被拒绝');
        throw Exception('需要麦克风权限');
      }
    }

    // 检查是否可用
    print('$TAG: 检查PCM16编码是否支持');
    final isAvailable = await _audioRecorder.isEncoderSupported(
      AudioEncoder.pcm16bits,
    );
    print('$TAG: PCM16编码支持状态: $isAvailable');

    // 设置音频模式 - 参考Android原生实现
    print('$TAG: 配置音频会话');
    final session = await AudioSession.instance;

    // 使用与原生Android实现更接近的配置
    if (Platform.isAndroid) {
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.allowBluetooth,
          avAudioSessionMode: AVAudioSessionMode.voiceChat,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.voiceCommunication,
            flags: AndroidAudioFlags.audibilityEnforced,
          ),
          androidAudioFocusGainType:
              AndroidAudioFocusGainType.gainTransientExclusive,
          androidWillPauseWhenDucked: false,
        ),
      );
    } else {
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.allowBluetooth,
          avAudioSessionMode: AVAudioSessionMode.voiceChat,
        ),
      );
      await session.setActive(true);
    }

    _isRecorderInitialized = true;
    print('$TAG: 录音器初始化成功');
  }

  /// 初始化音频播放器
  static Future<void> initPlayer() async {
    // 确保任何旧播放器被释放
    await stopPlaying();

    try {
      print('$TAG: 初始化音频播放器 - 单声道 16kHz');

      // 初始化为单声道，匹配 Opus 解码器输出
      _mpAudioStream.init(
        channels: AppConfig.channels, // 使用单声道，匹配 Opus
        sampleRate: AppConfig.sampleRate, // 16000 Hz
      );
      _mpAudioStream.resume(); // 开始播放

      _isPlayerInitialized = true;
      print(
        '$TAG: 音频播放器初始化成功 - ${AppConfig.channels}声道 ${AppConfig.sampleRate}Hz',
      );
    } catch (e) {
      print('$TAG: 音频播放器初始化失败: $e');
      _isPlayerInitialized = false;
    }
  }

  /// 播放Opus音频数据
  static Future<void> playOpusData(Uint8List opusData) async {
    try {
      // 如果播放器未初始化，先初始化
      if (!_isPlayerInitialized) {
        await initPlayer();
      }

      //print('$TAG: 接收到 Opus 数据: ${opusData.length} 字节');

      // 解码Opus数据
      final Int16List pcmData = _decoder.decode(input: opusData);
      //print('$TAG: 解码后 PCM 数据: ${pcmData.length} 样本');

      // 转换 Int16 PCM 数据到 Float32 格式 (mp_audio_stream 需要)
      final Float32List float32Data = Float32List(pcmData.length);
      for (int i = 0; i < pcmData.length; i++) {
        // 归一化到 -1.0 到 1.0 范围
        float32Data[i] = pcmData[i] / 32768.0;
      }

      //print('$TAG: 转换为 Float32 数据: ${float32Data.length} 样本');
      //print('$TAG: 前几个样本值: ${float32Data.take(5).toList()}');

      // 发送到 mp_audio_stream
      _mpAudioStream.push(float32Data);
      //print('$TAG: 音频数据已推送到播放器');
    } catch (e, stackTrace) {
      print('$TAG: 播放失败: $e');
      print('$TAG: 堆栈: $stackTrace');

      // 简单重置并重新初始化
      await stopPlaying();
      await initPlayer();
    }
  }

  /// 停止播放
  static Future<void> stopPlaying() async {
    if (_isPlayerInitialized) {
      try {
        // mp_audio_stream 没有 stop 方法，使用 dispose 来完全释放
        // 或者简单地标记为未初始化，需要时重新初始化
        print('$TAG: 播放器已停止');
      } catch (e) {
        print('$TAG: 停止播放失败: $e');
      }
      _isPlayerInitialized = false;
    }
  }

  /// 释放资源
  static Future<void> dispose() async {
    _audioStreamController.close();
    print('$TAG: 资源已释放');
  }

  /// 开始录音
  /// [enableAEC] - 是否启用回声消除（AEC）和降噪，持续监听模式建议开启
  static Future<void> startRecording({bool enableAEC = false}) async {
    if (!_isRecorderInitialized) {
      await initRecorder();
    }

    if (_isRecording) return;

    try {
      print('$TAG: 尝试启动录音 (AEC: $enableAEC)');

      // 确保麦克风权限已获取 - 使用不同方式检查权限
      final status = await Permission.microphone.status;
      print('$TAG: 麦克风权限状态: $status');

      if (status != PermissionStatus.granted) {
        final result = await Permission.microphone.request();
        print('$TAG: 请求麦克风权限结果: $result');
        if (result != PermissionStatus.granted) {
          print('$TAG: 麦克风权限被拒绝');
          return;
        }
      }

      // 尝试直接使用音频流
      try {
        print('$TAG: 尝试启动流式录音 (AEC: $enableAEC, 降噪: $enableAEC, AGC: $enableAEC)');
        final stream = await _audioRecorder.startStream(
          RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: AppConfig.sampleRate,
            numChannels: AppConfig.channels,
            // 🔥 AEC 回声消除 - 持续监听模式下需要消除扬声器播放的回声
            echoCancel: enableAEC,
            // 🔥 降噪 - 减少背景噪音
            noiseSuppress: enableAEC,
            // 🔥 自动增益控制 - 自动调整麦克风音量
            autoGain: enableAEC,
          ),
        );

        _isRecording = true;
        print('$TAG: 流式录音启动成功');

        // 🔥 启动振幅监听
        _amplitudeStreamController = StreamController<double>.broadcast();
        _amplitudeSubscription = _audioRecorder
            .onAmplitudeChanged(const Duration(milliseconds: 100))
            .listen((amp) {
          // 将 dBFS (-60 ~ 0) 转换为 0.0 ~ 1.0
          // dBFS 是负值，0 表示最大音量，-60 表示静音
          final normalized = ((amp.current + 50) / 50).clamp(0.0, 1.0);
          _amplitudeStreamController?.add(normalized);
        });

        // 直接从流中处理数据
        stream.listen(
          (data) async {
            if (data.isNotEmpty && data.length % 2 == 0) {
              final opusData = await encodeToOpus(data);
              if (opusData != null) {
                _audioStreamController.add(opusData);
              }
            }
          },
          onError: (error) {
            print('$TAG: 音频流错误: $error');
            _isRecording = false;
          },
          onDone: () {
            print('$TAG: 音频流结束');
            _isRecording = false;
          },
        );
      } catch (e) {
        print('$TAG: 流式录音失败: $e');
        _isRecording = false;
        rethrow;
      }
    } catch (e, stackTrace) {
      print('$TAG: 启动录音失败: $e');
      print(stackTrace);
      _isRecording = false;
    }
  }

  /// 停止录音
  static Future<String?> stopRecording() async {
    if (!_isRecorderInitialized || !_isRecording) return null;

    // 取消定时器
    _audioProcessingTimer?.cancel();

    // 🔥 取消振幅订阅
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    await _amplitudeStreamController?.close();
    _amplitudeStreamController = null;

    // 停止录音
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      print('$TAG: 停止录音: $path');
      return path;
    } catch (e) {
      print('$TAG: 停止录音失败: $e');
      _isRecording = false;
      return null;
    }
  }

  /// 将PCM数据编码为Opus格式
  static Future<Uint8List?> encodeToOpus(Uint8List pcmData) async {
    try {
      // 删除频繁日志
      // 转换PCM数据为Int16List (小端字节序，与Android一致)
      final Int16List pcmInt16 = Int16List.fromList(
        List.generate(
          pcmData.length ~/ 2,
          (i) => (pcmData[i * 2]) | (pcmData[i * 2 + 1] << 8),
        ),
      );

      // 确保数据长度符合Opus要求（必须是2.5ms、5ms、10ms、20ms、40ms或60ms的采样数）
      final int samplesPerFrame =
          (AppConfig.sampleRate * AppConfig.frameDuration) ~/ 1000;

      Uint8List encoded;

      // 处理过短的数据
      if (pcmInt16.length < samplesPerFrame) {
        // 对于过短的数据，可以通过添加静音来填充到所需长度
        final Int16List paddedData = Int16List(samplesPerFrame);
        for (int i = 0; i < pcmInt16.length; i++) {
          paddedData[i] = pcmInt16[i];
        }

        // 编码填充后的数据
        encoded = Uint8List.fromList(_encoder.encode(input: paddedData));
      } else {
        // 对于足够长的数据，裁剪到精确的帧长度
        encoded = Uint8List.fromList(
          _encoder.encode(input: pcmInt16.sublist(0, samplesPerFrame)),
        );
      }

      return encoded;
    } catch (e, stackTrace) {
      print('$TAG: Opus编码失败: $e');
      print(stackTrace);
      return null;
    }
  }

  /// 检查是否正在录音
  static bool get isRecording => _isRecording;

  /// 检查是否正在播放
  static bool get isPlaying => _isPlaying;
}
