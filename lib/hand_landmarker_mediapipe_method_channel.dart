import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hand_landmarker_mediapipe_platform_interface.dart';


class MethodChannelHandLandmarkerMediapipe extends HandLandmarkerMediapipePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('hand_landmarker_mediapipe');
  late final Future<void>?
    Function(List<Hand> handLandmarks)? _onHandDetected;

  @override
  Future<void> init({
    required double minHandDetectionConfidence,
    required double minHandTrackingConfidence,
    required double minHandPresenceConfidence,
    required int maxNumHands,
    required Delegate currentDelegate,
    required RunningMode runningMode,
    Future<void> Function(List<Hand>? hands)? onHandDetected
  }) async {
    _onHandDetected = onHandDetected;
    await _setupNativeCallbacks();
    await methodChannel.invokeMethod(
      'initialize',
      <String, Object>{
        'minHandDetectionConfidence': minHandDetectionConfidence,
        'minHandTrackingConfidence': minHandTrackingConfidence,
        'minHandPresenceConfidence': minHandPresenceConfidence,
        'maxNumHands': maxNumHands,
        'currentDelegate': currentDelegate.index,
        'runningMode': runningMode.index
      }
    );
    await setupHandLandmarker();
  }

  Future<void> _setupNativeCallbacks() async {
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onLandmarkResults':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          final landmarks = (args['landmarks'] as List)
              .cast<List<Map<String, double>>>();
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

  Future<void> _onLandmarkResults(List<List<Map<String, double>>> results) async {
    var hands = await _resultToHandList(results);
    log("##################### RESULTS!");
    await _onHandDetected!(hands!);
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
    await methodChannel.invokeMethod(
      'detectLiveStream',
      <String, Object>{
        'imageData': imageData,
        'isFrontCamera': isFrontCamera,
      },
    );
  }

  @override
  Future<List<Hand>?> detectVideoFile({
    required XFile videoFile,
    required int inferenceIntervalMs
  }) async {
    final result = await methodChannel
        .invokeListMethod<List<Map<String, double>>>('detectVideoFile');
    return await _resultToHandList(result!);
  }

  @override
  Future<List<Hand>?> detectImage({
    required Uint8List imageData,
    required int width,
    required int height
  }) async {
    final result = await methodChannel
      .invokeListMethod<List<Map<String, double>>>(
      'detectImage',
      <String, Object> {
        'imageData': imageData
      }
    );

    return await _resultToHandList(result!);
  }

  Future<List<Hand>?> _resultToHandList(
    List<List<Map<String, double>>> results
  ) async {
    List<Hand>? hands;
    for (var handResult in results) {
      List<HandLandmark>? tempLandmarks;
      for (var landmark in handResult) {
        tempLandmarks!.add(
            HandLandmark(
                x: landmark['x']!,
                y: landmark['y']!,
                z: landmark['z']!)
        );
      }
      hands!.add(Hand(landmarks: tempLandmarks!));
    }
    return hands;
  }
}
