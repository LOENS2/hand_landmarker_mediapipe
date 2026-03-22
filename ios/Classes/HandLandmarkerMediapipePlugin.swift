import Flutter
import UIKit

public class HandLandmarkerMediapipePlugin: NSObject, FlutterPlugin {
    var handLandmarkerService : HandLandmarkerService?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "hand_landmarker_mediapipe", binaryMessenger: registrar.messenger())
        let instance = HandLandmarkerMediapipePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "BAD_ARGS", message: "Arguments have to be a map", details: nil))
                return
            }

            let minHandDetectionConfidence = (args["minHandDetectionConfidence"] as? NSNumber)?.doubleValue ??
                InferenceConfigurationManager.sharedInstance.minHandDetectionConfidence
            let minHandTrackingConfidence = (args["minHandTrackingConfidence"] as? NSNumber)?.doubleValue ?? InferenceConfigurationManager.sharedInstance.minHandTrackingConfidence
            let minHandPresenceConfidence = (args["minHandPresenceConfidence"] as? NSNumber)?.doubleValue ??
                InferenceConfigurationManager.sharedInstance.minHandPresenceConfidence
            let maxNumHands = (args["maxNumHands"] as? NSNumber)?.intValue ??
                InferenceConfigurationManager.sharedInstance.numHands
            let currentDelegate = HandLandmarkerDelegate(
                index: <#T##Int#>(args["currentDelegate"] as? NSNumber)?.intValue
                )? ??
                InferenceConfigurationManager.sharedInstance.delegate
            let runningMode = (args["runningMode"] as? NSNumber)?.intValue ?? 0

            switch (runningMode) {
            case 0: // image
                handLandmarkerService = HandLandmarkerService.stillImageLandmarkerService(
                    modelPath: InferenceConfigurationManager.sharedInstance.modelPath,
                    numHands: maxNumHands,
                    minHandDetectionConfidence: minHandDetectionConfidence,
                    minHandPresenceConfidence: minHandPresenceConfidence,
                    minTrackingConfidence: minHandTrackingConfidence,
                    delegate: currentDelegate
                )
            case 1: // video
                handLandmarkerService = HandLandmarkerService.videoHandLandmarkerService(
                    modelPath: InferenceConfigurationManager.sharedInstance.modelPath,
                    numHands: maxNumHands,
                    minHandDetectionConfidence: minHandDetectionConfidence,
                    minHandPresenceConfidence: minHandPresenceConfidence,
                    minTrackingConfidence: minHandTrackingConfidence,
                    videoDelegate: self,
                    delegate: currentDelegate
                )
            case 2: // live stream3
                handLandmarkerService = HandLandmarkerService
                    .liveStreamHandLandmarkerService(
                        modelPath: InferenceConfigurationManager.sharedInstance.modelPath,
                        numHands: maxNumHands,
                        minHandDetectionConfidence: minHandDetectionConfidence,
                        minHandPresenceConfidence: minHandPresenceConfidence,
                        minTrackingConfidence: minHandTrackingConfidence,
                        liveStreamDelegate: self,
                        delegate: currentDelegate
                    )
                }
            default:
                result(FlutterError(code: "BAD_RUNNING_MODE", message: "Invalid running mode index", details: nil)))
                return
            }

            result(FlutterReply(success: true))
        case "clearHandLandmarker":
            handLandmarkerService.call.clearHandLandmarker()
            result(nil)
        case "isClose":
            let result : NSNumber = NSNumber(value: handLandmarkerService.call.isClose())
            result(result)
        case "setupHandLandmarker":
            handLandmarkerService.call.setupHandLandmarker()
            result(FlutterReply(success: true))
        case "detectLiveStream":
            handLandmarkerService
            result(nil)
        case "detectVideoFile":
            result(nil)
        case "detectImage":
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func resultBundleToList(resultBundle: ResultBundle) -> [Array{Array{Dictionary}}] {
        var handList: [Array<Array<Dictionary>>] = []
        for hand in resultBundle.handLandmarkerResults {
            handList.append(hand.landmarks.map(\.data))
        }
        return handList
    }
}
