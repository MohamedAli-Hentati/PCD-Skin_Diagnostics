package com.example.app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.core.graphics.scale
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.*
import org.pytorch.*
import org.pytorch.torchvision.*
import kotlin.math.exp

class MainActivity: FlutterActivity() {
    private val channel = "app.android/channel"

    private fun assetFilePath(context: Context, asset: String): String {
        val file = File(context.filesDir, asset)
        try {
            val inpStream: InputStream = context.assets.open(asset)
            try {
                val outStream = FileOutputStream(file, false)
                val buffer = ByteArray(4 * 1024)
                var read: Int

                while (true) {
                    read = inpStream.read(buffer)
                    if (read == -1) {
                        break
                    }
                    outStream.write(buffer, 0, read)
                }
                outStream.flush()
            } catch (exception: Exception) {
                exception.printStackTrace()
            }
            return file.absolutePath
        } catch (exception: Exception) {
            exception.printStackTrace()
        }
        return ""
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == "scanImage") {
                try {
                    val imagePath = call.arguments as String
                    val image: Bitmap = BitmapFactory.decodeFile(imagePath).scale(224, 224)
                    val model: Module = LiteModuleLoader.load(assetFilePath(this, "model.ptl"))
                    val normMean: FloatArray = floatArrayOf(0.6617725F, 0.49528646F, 0.42680266F)
                    val normStd: FloatArray = floatArrayOf(0.19104528F, 0.17559084F, 0.18125527F)
                    val inputTensor: Tensor = TensorImageUtils.bitmapToFloat32Tensor(image, normMean, normStd, MemoryFormat.CHANNELS_LAST)
                    val outputTensor: Tensor = model.forward(IValue.from(inputTensor)).toTensor()
                    val scores: FloatArray = outputTensor.dataAsFloatArray
                    var maxScore = -Float.MAX_VALUE
                    var maxScoreIndex: Int = -1
                    for (i in 0 until scores.count()) {
                        if (scores[i] > maxScore) {
                            maxScore = scores[i]
                            maxScoreIndex = i
                        }
                    }
                    var sumExp = 0.0f
                    for (score in scores) {
                        sumExp += exp(score.toDouble()).toFloat()
                    }
                    val probabilities = FloatArray(scores.size)
                    for (i in scores.indices) {
                        probabilities[i] = exp(scores[i].toDouble()).toFloat() / sumExp
                    }
                    val map = HashMap<String, Any>()
                    map["label_id"] = maxScoreIndex
                    map["confidence"] = probabilities[maxScoreIndex]
                    result.success(map)
                } catch (exception: Exception) {
                    result.error(exception.toString(), null, null)
                }
            }
        }
    }
}