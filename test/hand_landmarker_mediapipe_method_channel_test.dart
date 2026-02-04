import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hand_landmarker_mediapipe/hand_landmarker_mediapipe_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelHandLandmarkerMediapipe platform = MethodChannelHandLandmarkerMediapipe();
  const MethodChannel channel = MethodChannel('hand_landmarker_mediapipe');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
