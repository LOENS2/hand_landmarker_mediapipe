import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hand_landmarker_mediapipe_platform_interface.dart';


class MethodChannelHandLandmarkerMediapipe extends HandLandmarkerMediapipePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('hand_landmarker_mediapipe');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> clearHandLandmarker() async {
    await methodChannel.invokeMethod('clearHandLandmarker');
  }

  @override
  Future<bool?> isClose() async {
    final result = await methodChannel.invokeMethod<bool>('isClose');
    return result;
  }

  @override
  Future<void> setupHandLandmarker() async {
    await methodChannel.invokeMethod('setupHandLandmarker');
  }

  @override
  Future<List<HandLandmark>?> detectLiveStream({
    required Map<String, Object> imageData,
    required bool isFrontCamera
  }) async {
    final result = await methodChannel.invokeListMethod<HandLandmark>(
      'detectLiveStreamWrapper',
      [
        imageData,
        isFrontCamera
      ]
    );
    return result;
  }

  @override
  Future<List<HandLandmark>?> detectVideoFile({
    required XFile videoFile,
    required int inferenceIntervalMs
  }) async {
    final result = await methodChannel
        .invokeListMethod<HandLandmark>('detectVideoFile');
    return result;
  }

  @override
  Future<List<HandLandmark>?> detectImage({
    required Uint8List imageData
  }) async {
    final result = await methodChannel
        .invokeListMethod<HandLandmark>('detectImage', imageData);
    return result;
  }
}
