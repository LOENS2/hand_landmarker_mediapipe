package com.loens2.hand_landmarker_mediapipe

import android.content.Context
import android.graphics.Bitmap
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
                val planes = imageDataMap?.get("planes") as? List<HashMap<String, Any>>

                if (planes == null) {
                    result.error(
                        "INVALID_DATA",
                        "The the planes cannot be null.",
                        null
                    )
                    return
                }

                if (planes.size != 3) {
                    result.error(
                        "INVALID_DATA_SIZE",
                        "The size of the planes list is incorrect.",
                        null
                    )
                    return
                }

                val width = imageDataMap["width"] as Int
                val height = imageDataMap["height"] as Int

                val yPlane = parsePlane(planes[0])
                val uPlane = parsePlane(planes[1])
                val vPlane = parsePlane(planes[2])

                val bitmap = yuv420ToBitmap(width, height, yPlane, uPlane, vPlane)

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

    data class FlutterPlane(
        val bytes: ByteArray,
        val bytesPerRow: Int,
        val bytesPerPixel: Int?
    ) {
        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false

            other as FlutterPlane

            if (bytesPerRow != other.bytesPerRow) return false
            if (bytesPerPixel != other.bytesPerPixel) return false
            if (!bytes.contentEquals(other.bytes)) return false

            return true
        }

        override fun hashCode(): Int {
            var result = bytesPerRow
            result = 31 * result + (bytesPerPixel ?: 0)
            result = 31 * result + bytes.contentHashCode()
            return result
        }
    }

    fun yuv420ToArgb8888(
        width: Int,
        height: Int,
        yPlane: FlutterPlane,
        uPlane: FlutterPlane,
        vPlane: FlutterPlane
    ): IntArray {
        val out = IntArray(width * height)

        val yBytes = yPlane.bytes
        val uBytes = uPlane.bytes
        val vBytes = vPlane.bytes

        val yRowStride = yPlane.bytesPerRow
        val uRowStride = uPlane.bytesPerRow
        val vRowStride = vPlane.bytesPerRow

        val uPixelStride = uPlane.bytesPerPixel ?: 1
        val vPixelStride = vPlane.bytesPerPixel ?: 1

        for (y in 0 until height) {
            val yRow = y * yRowStride
            val uvRow = (y / 2)

            for (x in 0 until width) {
                val yIndex = yRow + x

                val uvX = x / 2
                val uIndex = uvRow * uRowStride + uvX * uPixelStride
                val vIndex = uvRow * vRowStride + uvX * vPixelStride

                val yValue = yBytes[yIndex].toInt() and 0xFF
                val uValue = uBytes[uIndex].toInt() and 0xFF
                val vValue = vBytes[vIndex].toInt() and 0xFF

                val yf = yValue.toFloat()
                val uf = (uValue - 128).toFloat()
                val vf = (vValue - 128).toFloat()

                var r = (yf + 1.402f * vf).roundToInt()
                var g = (yf - 0.344136f * uf - 0.714136f * vf).roundToInt()
                var b = (yf + 1.772f * uf).roundToInt()

                r = r.coerceIn(0, 255)
                g = g.coerceIn(0, 255)
                b = b.coerceIn(0, 255)

                out[y * width + x] =
                    (0xFF shl 24) or
                            (r shl 16) or
                            (g shl 8) or
                            b
            }
        }

        return out
    }

    fun yuv420ToBitmap(
        width: Int,
        height: Int,
        yPlane: FlutterPlane,
        uPlane: FlutterPlane,
        vPlane: FlutterPlane
    ): Bitmap {
        val argb = yuv420ToArgb8888(width, height, yPlane, uPlane, vPlane)
        return Bitmap.createBitmap(argb, width, height, Bitmap.Config.ARGB_8888)
    }

    fun parsePlane(map: Map<String, Any>): FlutterPlane {
        return FlutterPlane(
            bytes = map["bytes"] as ByteArray,
            bytesPerRow = map["bytesPerRow"] as Int,
            bytesPerPixel = map["bytesPerPixel"] as? Int
        )
    }
}
