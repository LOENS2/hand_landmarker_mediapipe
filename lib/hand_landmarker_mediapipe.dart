
import 'hand_landmarker_mediapipe_platform_interface.dart';

class HandLandmarkerMediapipe {
  Future<String?> getPlatformVersion() {
    return HandLandmarkerMediapipePlatform.instance.getPlatformVersion();
  }
}
