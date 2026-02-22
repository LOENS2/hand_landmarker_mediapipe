import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hand_landmarker_mediapipe/hand_landmarker_mediapipe.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _handLandmarkerMediapipePlugin = HandLandmarkerMediapipe();
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final _cameraDescription = (await availableCameras()).first;
    _cameraController = CameraController(
        _cameraDescription,
        ResolutionPreset.high
    );

    await _cameraController!.initialize();

    _handLandmarkerMediapipePlugin.setupHandLandmarker();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body:  FutureBuilder<void>(
          future: _cameraController!.initialize(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Center(
                  child: CameraPreview(_cameraController!),
                );
              } else {
                return CircularProgressIndicator();
              }
            }
        ),
      ),
    );
  }
}
