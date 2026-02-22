import 'dart:typed_data';
import 'package:camera/camera.dart';

import 'hand_landmarker_mediapipe_platform_interface.dart';

class HandLandmarkerMediapipe {


  Future<String?> getPlatformVersion() {
    return HandLandmarkerMediapipePlatform.instance.getPlatformVersion();
  }

  Future<void> clearHandLandmarker() async {
    HandLandmarkerMediapipePlatform.instance.clearHandLandmarker();
  }

  Future<bool?> isClose() async {
    return HandLandmarkerMediapipePlatform.instance.isClose();
  }

  Future<void> setupHandLandmarker() async {
    HandLandmarkerMediapipePlatform.instance.setupHandLandmarker();
  }

  Future<List<HandLandmark>?> detectLiveStream({
    required CameraImage cameraImage,
    required bool isFrontCamera
  }) async {
    final imageData = {
      'width': cameraImage.width,
      'height': cameraImage.height,
      'plane': cameraImage.planes.first.bytes,
    };

    return HandLandmarkerMediapipePlatform.instance.detectLiveStream(
        imageData: imageData,
        isFrontCamera: isFrontCamera
    );
  }

  Future<List<HandLandmark>?> detectVideoFile({
    required XFile videoFile,
    required int inferenceIntervalMs
  }) async {
    return HandLandmarkerMediapipePlatform.instance.detectVideoFile(
        videoFile: videoFile, inferenceIntervalMs: inferenceIntervalMs
    );
  }

  Future<List<HandLandmark>?> detectImage({
    required Uint8List imageData
  }) async {
    return HandLandmarkerMediapipePlatform.instance
        .detectImage(imageData: imageData);
  }
}
