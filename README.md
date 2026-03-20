# Hand Landmarker MediaPipe

> [!CAUTION]
> 
> This code is still WIP. 
> It is not ready for production use.
> I wrote this code to achieve proper performance in hand landmarking with Flutter and MediaPipe. 

Native implementation of the MediaPipe hand landmarker through method channels.

## Getting Started

### Using the package

1. Add the package to your pubspec.yaml file
2. Initialize the `HandLandmarkerMediapipe` class:
```dart
var handLandmarker = HandLandmarkerMediapipe(
  minHandDetectionConfidence:
    HandLandmarkerMediapipe.defaultHandDetectionConfidence,
  minHandTrackingConfidence:
    HandLandmarkerMediapipe.defaultHandTrackingConfidence,
  minHandPresenceConfidence:
    HandLandmarkerMediapipe.defaultHandPresenceConfidence,
  maxNumHands: HandLandmarkerMediapipe.defaultNumHands,
  currentDelegate: Delegate.gpu, // GPU is more performant, but won't work on every device.
  runningMode: RunningMode.image,
  onHandDetected: _onHandDetected, // Only required for RunningMode.liveStream 
);
```
3. Depending on your use case either use the `detectImage()`, `detectVideoFile()` or `detectLiveStream()` methods.
<details>
  <summary>detectImage()</summary>

You can pass a Uint8List of the image bytes to the `detectImage()` method. \
Be sure to set the `runningMode` to `RunningMode.image`.\
The method returns a `List<Hand>` object.
```dart
var results = await handLandmarker.detectImage(
  imageData: testImageBytes.buffer.asUint8List(),
);
```
</details>
<details>
  <summary>detectVideoFile()</summary>

You can pass a XFile of thi video as well as the inference intorval to the `detectVideoFile()` method.\
Be sure to set the `runningMode` to `RunningMode.video`.\
The method returns a `List<Hand>` object.
```dart
var test = await handLandmarker.detectVideoFile(
  videoFile: videoFile,
  inferenceIntervalMs: inferenceIntervalMs
);
```
</details>
<details>
  <summary>detectImage()</summary>

You can pass a CameraImage to the `detectLiveStream()` method.\
Be sure to set the `runningMode` to `RunningMode.liveStream`.\
Once the inference is done, the `onHandDetected` callback will be called.
```dart
await _plugin!.detectLiveStream(
  cameraImage: image,
  isFrontCamera: _controller?.description.lensDirection == CameraLensDirection.front
);
```

Example for `onHandDetected` callback:
```dart
Future<void> _onHandDetected(List<Hand>? hands) async {
  log("Landmarks:");
  for (var hand in hands!) {
    for (var landmark in hand.landmarks) {
      log("x: ${landmark.x}, y: ${landmark.y}, z: ${landmark.z}");
    }
  }
}
```
</details>

## ToDo

- [ ] Add more documentation
- [ ] Add more examples
- [ ] Add more tests
- [ ] Add iOS support