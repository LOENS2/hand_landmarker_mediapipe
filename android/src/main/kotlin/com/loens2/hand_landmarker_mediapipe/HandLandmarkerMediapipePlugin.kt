package com.loens2.hand_landmarker_mediapipe

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import android.net.Uri
import android.os.Handler
import android.os.Looper
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
import java.io.ByteArrayOutputStream
import kotlin.math.roundToInt

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
    private val mainHandler = Handler(Looper.getMainLooper())

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
                        mainHandler.post {
                            channel.invokeMethod(
                                "onLandmarkError",
                                hashMapOf(
                                    "message" to error,
                                    "code" to errorCode
                                )
                            )
                        }
                    }

                    override fun onResults(resultBundle: HandLandmarkerHelper.ResultBundle) {
                        val landmarkList = resultBundleToList(resultBundle)
                        mainHandler.post {
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
                }

                android.util.Log.d(
                    "HandLandmarkerPlugin",
                    "initialize: runningMode=$runningMode currentDelegate=$currentDelegate maxNumHands=$maxNumHands"
                )

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
                val imageRaw = imageDataMap?.get("plane") as ByteArray?

                if (imageRaw == null) {
                    result.error(
                        "INVALID_DATA",
                        "The the planes cannot be null.",
                        null
                    )
                    return
                }

                val width = imageDataMap["width"] as Int
                val height = imageDataMap["height"] as Int

                val bitmap = nv21ToBitmap(imageRaw, width, height)
                    ?: throw Exception("Failed to decode NV21 image")

                val isFrontCamera = call.argument<Boolean>("isFrontCamera")
                handLandmankerHelper?.detectLiveStream(bitmap, isFrontCamera ?: false)

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
                // Fetch and decode the image first
                val imageData = call.argument<ByteArray>("imageData") ?: byteArrayOf()
                val imageBitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)

                // Run the landmarking process on the image.
                val data = handLandmankerHelper?.detectImage(imageBitmap)
                val landmarkList = resultBundleToList(data)

                // Return the result to flutter
                result.success(landmarkList)
            }

            // This is just to prevent the stupidity of any programmers working on the Flutter side.
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

    private fun nv21ToBitmap(imageData: ByteArray, width: Int, height: Int): Bitmap? {
        // This conversion from NV21 to an RGBA bitmop is awful, but it works.
        val yuvImage = YuvImage(imageData, ImageFormat.NV21, width, height, null)
        val out = ByteArrayOutputStream()
        yuvImage.compressToJpeg(Rect(0, 0, width, height), 90, out)
        val imageBytes = out.toByteArray()
        return BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
    }
}
