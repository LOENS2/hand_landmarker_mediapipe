import 'package:flutter_test/flutter_test.dart';
import 'package:hand_landmarker_mediapipe/hand_landmarker_mediapipe.dart';
import 'package:hand_landmarker_mediapipe/hand_landmarker_mediapipe_platform_interface.dart';
import 'package:hand_landmarker_mediapipe/hand_landmarker_mediapipe_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHandLandmarkerMediapipePlatform
    with MockPlatformInterfaceMixin
    implements HandLandmarkerMediapipePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HandLandmarkerMediapipePlatform initialPlatform = HandLandmarkerMediapipePlatform.instance;

  test('$MethodChannelHandLandmarkerMediapipe is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHandLandmarkerMediapipe>());
  });

  test('getPlatformVersion', () async {
    HandLandmarkerMediapipe handLandmarkerMediapipePlugin = HandLandmarkerMediapipe();
    MockHandLandmarkerMediapipePlatform fakePlatform = MockHandLandmarkerMediapipePlatform();
    HandLandmarkerMediapipePlatform.instance = fakePlatform;

    expect(await handLandmarkerMediapipePlugin.getPlatformVersion(), '42');
  });
}
