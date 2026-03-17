package com.loens2.hand_landmarker_mediapipe

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import androidx.core.graphics.createBitmap
import com.google.mediapipe.tasks.vision.core.RunningMode
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.loens2.hand_landmarker_mediapipe.hand_landmarker.HandLandmarkerHelper
import java.nio.ByteBuffer
import androidx.core.net.toUri

/** HandLandmarkerMediapipePlugin */
class HandLandmarkerMediapipePlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var appContext: Context

    private var handLandmankerHelper: HandLandmarkerHelper? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        appContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "hand_landmarker_mediapipe")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "initialize" -> {
                val minHandDetectionConfidence = call.argument<Double>("minHandDetectionConfidence") ?: 0.0
                val minHandTrackingConfidence = call.argument<Double>("minHandTrackingConfidence") ?: 0.0
                val minHandPresenceConfidence = call.argument<Double>("minHandPresenceConfidence") ?: 0.0
                val maxNumHands = call.argument<Int>("maxNumHands") ?: 0
                val currentDelegate = call.argument<Int>("currentDelegate") ?: 0
                val runningMode = call.argument<Int>("runningMode") ?: 0
                val handLandmarkerHelperListener = object : HandLandmarkerHelper.LandmarkerListener {
                    override fun onError(error: String, errorCode: Int) {
                        channel.invokeMethod(
                            "onLandmarkError",
                            hashMapOf(
                                "message" to error,
                                "code" to errorCode
                            )
                        )
                    }

                    override fun onResults(resultBundle: HandLandmarkerHelper.ResultBundle) {
                        val landmarkList = resultBundleToList(resultBundle)
                        channel.invokeMethod(
                            "onLandmarkResults",
                            hashMapOf(
                                "inferenceTimeMs" to resultBundle.inferenceTime,
                                "imageWidth" to resultBundle.inputImageWidth,
                                "imageHeight" to resultBundle.inputImageHeight,
                                "landmarks" to landmarkList
                            )
                        )
                    }
                }

                handLandmankerHelper = HandLandmarkerHelper(
                    minHandDetectionConfidence = minHandDetectionConfidence.toFloat(),
                    minHandTrackingConfidence = minHandTrackingConfidence.toFloat(),
                    minHandPresenceConfidence = minHandPresenceConfidence.toFloat(),
                    maxNumHands = maxNumHands,
                    currentDelegate = currentDelegate,
                    runningMode = RunningMode.entries[runningMode],
                    context = appContext,
                    handLandmarkerHelperListener = handLandmarkerHelperListener
                )

                result.success(null)
            }

            "clearHandLandmarker" -> {
                handLandmankerHelper?.clearHandLandmarker()
                result.success(null)
            }

            "isClose" -> result.success(handLandmankerHelper?.isClose() ?: false)
            "setupHandLandmarker" -> {
                handLandmankerHelper?.setupHandLandmarker()
                result.success(null)
            }

            "detectLiveStream" -> {
                val imageDataMap = call.argument<HashMap<String, Any>>("imageData")
                val bufferList = imageDataMap?.get("plane") as ByteArray?
                val buffer = ByteBuffer.allocateDirect(bufferList?.size ?: 0)
                if (bufferList != null) {
                    for (item in bufferList) {
                        buffer.put(item)
                    }
                }
                val imageData = HandLandmarkerHelper.ImageData(
                    buffer,
                    (imageDataMap?.get("width") ?: 0) as Int,
                    (imageDataMap?.get("height") ?: 0) as Int
                )
                val isFrontCamera = call.argument<Boolean>("isFrontCamera")
                handLandmankerHelper?.detectLiveStream(imageData, isFrontCamera ?: false)

                result.success(null)
            }

            "detectVideoFile" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val inferenceIntervalMs = call.argument<Int>("inferenceIntervalMs") ?: 0
                val data = handLandmankerHelper?.detectVideoFile(
                    filePath.toUri(),
                    inferenceIntervalMs.toLong()
                )

                val landmarkList = resultBundleToList(data)
                result.success(landmarkList)
            }

            "detectImage" -> {
                val imageData = call.argument<ByteArray>("imageData") ?: byteArrayOf()
                val height = call.argument<Int>("height") ?: 0
                val width = call.argument<Int>("width") ?: 0
                val imageBitmap = createBitmap(width, height)
                val buffer = ByteBuffer.allocate(imageData.size)
                for (item in imageData) {
                    buffer.put(item)
                }
                imageBitmap.copyPixelsFromBuffer(buffer)
                val data = handLandmankerHelper?.detectImage(imageBitmap)
                val landmarkList = resultBundleToList(data)
                result.success(landmarkList)
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun resultBundleToList(resultBundle: HandLandmarkerHelper.ResultBundle?):
            MutableList<MutableList<HashMap<String, Double>>> {
        val handList: MutableList<MutableList<HashMap<String, Double>>> = mutableListOf()
        resultBundle?.results?.forEach { handResult ->
            val landmarkList: MutableList<HashMap<String, Double>> = mutableListOf()
            handResult.landmarks().forEach { landmarks ->
                landmarks.forEach { landmark ->
                    landmarkList.add(
                        hashMapOf(
                            "x" to landmark.x().toDouble(),
                            "y" to landmark.y().toDouble(),
                            "z" to landmark.z().toDouble(),
                        )
                    )
                }
            }
            handList.add(landmarkList)
        }
        return handList
    }
}
