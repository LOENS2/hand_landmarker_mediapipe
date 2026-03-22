import Flutter
import UIKit

public class HandLandmarkerMediapipePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "hand_landmarker_mediapipe", binaryMessenger: registrar.messenger())
    let instance = HandLandmarkerMediapipePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      //let minHandDetectionConfidence = call.argument<Double>("minHandDetectionConfidence")
      //let minHandTrackingConfidence = call.argument<Double>("minHandTrackingConfidence")
      //let minHandPresenceConfidence = call.argument<Double>("minHandPresenceConfidence")
      //let maxNumHands = call.argument<Int>("maxNumHands")
      //let currentDelegate = call.argument<Int>("currentDelegate")
      //let runningMode = call.argument<Int>("runningMode")
        result(nil)
    case "clearHandLandmarker":
      result(nil)
    case "isClose":
      result(nil)
    case "setupHandLandmarker":
      result(nil)
    case "detectLiveStream":
      result(nil)
    case "detectVideoFile":
      result(nil)
    case "detectImage":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
