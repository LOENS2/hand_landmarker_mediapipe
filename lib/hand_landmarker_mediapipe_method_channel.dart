import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hand_landmarker_mediapipe_platform_interface.dart';


class MethodChannelHandLandmarkerMediapipe extends HandLandmarkerMediapipePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('hand_landmarker_mediapipe');
  late final Future<void>
    Function(List<HandLandmark>? handLandmarks) _onHandDetected;

  @override
  Future<void> init({
    required double minHandDetectionConfidence,
    required double minHandTrackingConfidence,
    required double minHandPresenceConfidence,
    required int maxNumHands,
    required Delegate currentDelegate,
    required RunningMode runningMode,
    required Future<void> Function(List<HandLandmark>? handLandmarks) onHandDetected
  }) async {
    _onHandDetected = onHandDetected;
    await setupHandLandmarker();
  }

  Future<void> setupNativeCallbacks() async {
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onLandmarkResults':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          final landmarks = (args['landmarks'] as List).cast<Map<String, double>>();
          await _onLandmarkResults(landmarks);
          return;
        case 'onLandmarkError':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          final message = args['message'] as String? ?? 'Unknown';
          final code = args['code'] as int? ?? 0;
          await _onLandmarkError(message, code);
          return;
        default:
          return;
      }
    });
  }

  Future<void> _onLandmarkResults(List<Map<String, double>> results) async {
    List<HandLandmark>? handLandmarks;
    for (var result in results) {
      handLandmarks!.add(
        HandLandmark(
          x: result['x']!,
          y: result['y']!,
          z: result['z']!)
      );
    }

    await _onHandDetected(handLandmarks);
  }

  Future<void> _onLandmarkError(String message, int code) async {
    log("An error orcurred while processing the landmarking:"
        " ${message}; ${code}");
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
  Future<void> detectLiveStream({
    required Map<String, Object> imageData,
    required bool isFrontCamera
  }) async {
    await methodChannel.invokeListMethod<HandLandmark>(
      'detectLiveStreamWrapper',
      [
        imageData,
        isFrontCamera
      ]
    );
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
    required Uint8List imageData,
    required int width,
    required int height
  }) async {
    final result = await methodChannel
        .invokeListMethod<HandLandmark>('detectImage', imageData);

    return result;
  }
}
