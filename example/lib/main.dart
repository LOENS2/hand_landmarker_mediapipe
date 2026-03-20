import 'dart:async';
import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Import the plugin's main class.
import 'package:hand_landmarker_mediapipe/hand_landmarker_mediapipe.dart';
import 'package:hand_landmarker_mediapipe/hand_landmarker_mediapipe_method_channel.dart';
import 'package:hand_landmarker_mediapipe/hand_landmarker_mediapipe_platform_interface.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Hand Landmarker Example',
      home: HandTrackerView(),
    );
  }
}

class HandTrackerView extends StatefulWidget {
  const HandTrackerView({super.key});

  @override
  State<HandTrackerView> createState() => _HandTrackerViewState();
}

class _HandTrackerViewState extends State<HandTrackerView> {
  CameraController? _controller;
  // The plugin instance that will handle all the heavy lifting.
  HandLandmarkerMediapipe? _plugin;
  // A flag to show a loading indicator while the camera and plugin are initializing.
  bool _isInitialized = false;
  // A guard to prevent processing multiple frames at once.
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final camera = _cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21
    );

    // Create an instance of our plugin with custom options.
    _plugin = HandLandmarkerMediapipe(
      minHandDetectionConfidence:
      HandLandmarkerMediapipe.defaultHandDetectionConfidence,
      minHandTrackingConfidence:
      HandLandmarkerMediapipe.defaultHandTrackingConfidence,
      minHandPresenceConfidence:
      HandLandmarkerMediapipe.defaultHandPresenceConfidence,
      maxNumHands: HandLandmarkerMediapipe.defaultNumHands,
      currentDelegate: Delegate.cpu,
      runningMode: RunningMode.liveStream,
      onHandDetected: _onHandDetected
    );

    await _controller!.initialize();
    await _controller!.startImageStream(_processCameraImage);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    // Stop the image stream and dispose of the controller.
    _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || !_isInitialized || _plugin == null) return;

    _isDetecting = true;

    try {
      // The detect method is now synchronous (not async).
      await _plugin!.detectLiveStream(
        cameraImage: image,
        isFrontCamera: false
      );
    } catch (e) {
      debugPrint('Error detecting landmarks: $e');
    } finally {
      // Allow the next frame to be processed.
      _isDetecting = false;
    }
  }

  Future<void> _onHandDetected(List<Hand>? hands) async {
    log("Landmarks");
    for (var hand in hands!) {
      for (var landmark in hand.landmarks) {
        log("x: ${landmark.x}, y: ${landmark.y}, z: ${landmark.z}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while initializing.
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final controller = _controller!;
    final previewSize = controller.value.previewSize!;
    final previewAspectRatio = previewSize.height / previewSize.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Live Hand Tracking')),
      body: Center(
        child: CameraPreview(controller)
      )
    );
  }
}