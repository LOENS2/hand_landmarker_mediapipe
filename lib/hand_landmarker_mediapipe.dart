import 'dart:typed_data';
import 'package:camera/camera.dart';

import 'hand_landmarker_mediapipe_platform_interface.dart';

class HandLandmarkerMediapipe {
  HandLandmarkerMediapipe({
    required double minHandDetectionConfidence,
    required double minHandTrackingConfidence,
    required double minHandPresenceConfidence,
    required int maxNumHands,
    required Delegate currentDelegate,
    required RunningMode runningMode,
    required Future<void> Function(List<Hand>? hands) onHandDetected
  }) {
    HandLandmarkerMediapipePlatform.instance.init(
        minHandDetectionConfidence: minHandDetectionConfidence,
        minHandTrackingConfidence: minHandTrackingConfidence,
        minHandPresenceConfidence: minHandPresenceConfidence,
        maxNumHands: maxNumHands,
        currentDelegate: currentDelegate,
        runningMode: runningMode,
        onHandDetected: onHandDetected
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
    required bool isFrontCamera
  }) async {
    List<Uint8List>? planes;

    final imageData = {
      'width': cameraImage.width,
      'height': cameraImage.height,
      'planes': cameraImage.planes.map((p) => {
        'bytes': p.bytes,
        'bytesPerRow': p.bytesPerRow,
        'bytesPerPixel': p.bytesPerPixel,
      }).toList(),
    };

    await HandLandmarkerMediapipePlatform.instance.detectLiveStream(
        imageData: imageData,
        isFrontCamera: isFrontCamera
    );
  }

  Future<List<Hand>?> detectVideoFile({
    required XFile videoFile,
    required int inferenceIntervalMs
  }) async {
    return await HandLandmarkerMediapipePlatform.instance.detectVideoFile(
        videoFile: videoFile, inferenceIntervalMs: inferenceIntervalMs
    );
  }

  Future<List<Hand>?> detectImage({
    required Uint8List imageData,
    required int width,
    required int height
  }) async {
    return await HandLandmarkerMediapipePlatform.instance.detectImage(
      imageData: imageData,
      width: width,
      height: height
    );
  }
}
