import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hand_landmarker_mediapipe_platform_interface.dart';

/// An implementation of [HandLandmarkerMediapipePlatform] that uses method channels.
class MethodChannelHandLandmarkerMediapipe extends HandLandmarkerMediapipePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hand_landmarker_mediapipe');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
