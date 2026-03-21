import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';

import 'hand_landmarker_mediapipe_platform_interface.dart';

class HandLandmarkerMediapipe {
  static const delegateCpu = 0;
  static const delegateGpu = 1;
  static const defaultHandDetectionConfidence = 0.5;
  static const defaultHandTrackingConfidence = 0.5;
  static const defaultHandPresenceConfidence = 0.5;
  static const defaultNumHands = 2;

  HandLandmarkerMediapipe({
    required double minHandDetectionConfidence,
    required double minHandTrackingConfidence,
    required double minHandPresenceConfidence,
    required int maxNumHands,
    required Delegate currentDelegate,
    required RunningMode runningMode,
    Future<void> Function(List<Hand>? hands)? onHandDetected,
  }) {
    HandLandmarkerMediapipePlatform.instance.init(
      minHandDetectionConfidence: minHandDetectionConfidence,
      minHandTrackingConfidence: minHandTrackingConfidence,
      minHandPresenceConfidence: minHandPresenceConfidence,
      maxNumHands: maxNumHands,
      currentDelegate: currentDelegate,
      runningMode: runningMode,
      onHandDetected: onHandDetected,
    );
  }

  Future<void> clearHandLandmarker() async {
    await HandLandmarkerMediapipePlatform.instance.clearHandLandmarker();
  }

  Future<bool?> isClose() async {
    return await HandLandmarkerMediapipePlatform.instance.isClose();
  }

  Future<void> setupHandLandmarker() async {
    await HandLandmarkerMediapipePlatform.instance.setupHandLandmarker();
  }

  Future<void> detectLiveStream({
    required CameraImage cameraImage,
    required bool isFrontCamera,
  }) async {
    if (Platform.isAndroid &&
        cameraImage.format.group != ImageFormatGroup.nv21) {
      throw Exception(
        "Wrong ImageFormatGroup! "
        "The image stream has to be NV21 encoded on Android!",
      );
    }

    final imageData = {
      'width': cameraImage.width,
      'height': cameraImage.height,
      'plane': cameraImage.planes.first.bytes,
    };

    await HandLandmarkerMediapipePlatform.instance.detectLiveStream(
      imageData: imageData,
      isFrontCamera: isFrontCamera,
    );
  }

  Future<List<Hand>?> detectVideoFile({
    required XFile videoFile,
    required int inferenceIntervalMs,
  }) async {
    return await HandLandmarkerMediapipePlatform.instance.detectVideoFile(
      videoFile: videoFile,
      inferenceIntervalMs: inferenceIntervalMs,
    );
  }

  Future<List<Hand>?> detectImage({required Uint8List imageData}) async {
    return await HandLandmarkerMediapipePlatform.instance.detectImage(
      imageData: imageData,
    );
  }
}

class HandLandmark {
  final double x;
  final double y;
  final double z;

  HandLandmark({required this.x, required this.y, required this.z});
}

class Hand {
  final List<HandLandmark> landmarks;

  Hand({required this.landmarks});
}

enum RunningMode { image, video, liveStream }

enum Delegate { cpu, gpu }
