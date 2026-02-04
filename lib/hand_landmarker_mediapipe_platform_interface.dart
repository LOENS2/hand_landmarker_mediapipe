import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hand_landmarker_mediapipe_method_channel.dart';

abstract class HandLandmarkerMediapipePlatform extends PlatformInterface {
  /// Constructs a HandLandmarkerMediapipePlatform.
  HandLandmarkerMediapipePlatform() : super(token: _token);

  static final Object _token = Object();

  static HandLandmarkerMediapipePlatform _instance = MethodChannelHandLandmarkerMediapipe();

  /// The default instance of [HandLandmarkerMediapipePlatform] to use.
  ///
  /// Defaults to [MethodChannelHandLandmarkerMediapipe].
  static HandLandmarkerMediapipePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HandLandmarkerMediapipePlatform] when
  /// they register themselves.
  static set instance(HandLandmarkerMediapipePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
