package com.loens2.hand_landmarker_mediapipe

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.loens2.hand_landmarker_mediapipe.hand_landmarker.HandLandmarkerHelper

/** HandLandmarkerMediapipePlugin */
class HandLandmarkerMediapipePlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var handLandmankerHelper: HandLandmarkerHelper? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "hand_landmarker_mediapipe")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "initialize" -> {
                handLandmankerHelper = HandLandmarkerHelper(
                    minHandDetectionConfidence = ,
                    minHandTrackingConfidence = ,
                    minHandPresenceConfidence = ,
                    maxNumHands = ,
                    currentDelegate = ,
                    runningMode = RunningMode,
                    handLandmarkerHelperListener = null
                );
            },
            "clearHandLandmarker" -> {
                handLandmankerHelper
            },
            "isClose" -> result.sucess(),
            "setupHandLandmarker" -> {
                handLandmankerHelper?.setupHandLandmarker()
                result.success()
            },
            "detectLiveStream" -> {
                val data = handLandmankerHelper?.detectLiveStream()
                result.success(data);
            },
            "detectVideoFile",
            "detectImage",
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
