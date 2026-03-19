import 'package:flutter/services.dart';
import 'package:hand_landmarker_mediapipe/hand_landmarker_mediapipe.dart';
import 'package:hand_landmarker_mediapipe/hand_landmarker_mediapipe_platform_interface.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test Hand Landmarking with image', (WidgetTester tester) async {
    var handLandmarker = HandLandmarkerMediapipe(
      minHandDetectionConfidence:
        HandLandmarkerMediapipe.defaultHandDetectionConfidence,
      minHandTrackingConfidence:
        HandLandmarkerMediapipe.defaultHandTrackingConfidence,
      minHandPresenceConfidence:
        HandLandmarkerMediapipe.defaultHandPresenceConfidence,
      maxNumHands: HandLandmarkerMediapipe.defaultNumHands,
      currentDelegate: Delegate.gpu,
      runningMode: RunningMode.image,
    );


    final assetPath = "assets/test/human-male-hand.jpg";
    final testImageBytes = await rootBundle.load(assetPath);

    var results = await handLandmarker.detectImage(
      imageData: testImageBytes.buffer.asUint8List(),
    );

    expect(results != null, true);

    for (var hand in results!) {
      for (var landmark in hand.landmarks) {
        print("x: ${landmark.x}, y: ${landmark.y}, z: ${landmark.z}");
      }
    }
  });
}
