import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';

import 'hand_landmarker_mediapipe_method_channel.dart';

abstract class HandLandmarkerMediapipePlatform extends PlatformInterface {
  HandLandmarkerMediapipePlatform() : super(token: _token);

  static final Object _token = Object();

  static HandLandmarkerMediapipePlatform _instance = MethodChannelHandLandmarkerMediapipe();

  static HandLandmarkerMediapipePlatform get instance => _instance;

  static set instance(HandLandmarkerMediapipePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init({
    required double minHandDetectionConfidence,
    required double minHandTrackingConfidence,
    required double minHandPresenceConfidence,
    required int maxNumHands,
    required Delegate currentDelegate,
    required RunningMode runningMode,
    Future<void> Function(List<Hand>? hands)? onHandDetected
  }) async {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> clearHandLandmarker() async {
    throw UnimplementedError('clearHandLandmarker() has not been implemented.');
  }

  Future<bool?> isClose() async {
    throw UnimplementedError('isClose() has not been implemented.');
  }

  Future<void> setupHandLandmarker() async {
    throw UnimplementedError('setupHandLandmarker() has not been implemented.');
  }

  Future<void> detectLiveStream({
    required Map<String, Object> imageData,
    required bool isFrontCamera
  }) async {
    throw UnimplementedError('detectLiveStream() has not been implemented.');
  }

  Future<List<Hand>?> detectVideoFile({
    required XFile videoFile,
    required int inferenceIntervalMs
  }) async {
    throw UnimplementedError('detectVideoFile() has not been implemented.');
  }

  Future<List<Hand>?> detectImage({
    required Uint8List imageData,
    required int width,
    required int height
  }) async {
    throw UnimplementedError('detectImage() has not been implemented.');
  }
}

class HandLandmark {
  final double x;
  final double y;
  final double z;

  HandLandmark({
    required this.x,
    required this.y,
    required this.z
  });
}

class Hand {
  final List<HandLandmark> landmarks;

  Hand({required this.landmarks});
}

enum RunningMode {
  image,
  video,
  liveStream
}

enum Delegate {
  cpu,
  gpu
}