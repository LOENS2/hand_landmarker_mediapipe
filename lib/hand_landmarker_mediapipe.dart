import 'dart:typed_data';
import 'package:camera/camera.dart';

import 'hand_landmarker_mediapipe_platform_interface.dart';

class HandLandmarkerMediapipe {
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
    final imageData = {
      'width': cameraImage.width,
      'height': cameraImage.height,
      'plane': cameraImage.planes.first.bytes,
    };

    await HandLandmarkerMediapipePlatform.instance.detectLiveStream(
        imageData: imageData,
        isFrontCamera: isFrontCamera
    );
  }

  Future<List<HandLandmark>?> detectVideoFile({
    required XFile videoFile,
    required int inferenceIntervalMs
  }) async {
    return await HandLandmarkerMediapipePlatform.instance.detectVideoFile(
        videoFile: videoFile, inferenceIntervalMs: inferenceIntervalMs
    );
  }

  Future<List<HandLandmark>?> detectImage({
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
