package com.example.app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.core.graphics.scale
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.*
import org.pytorch.*
import org.pytorch.torchvision.*
import kotlin.math.exp

class MainActivity: FlutterActivity() {
    private val channel = "app.android/channel"
    fun assetFilePath(context: Context, assetName: String): String? {
        val file = File(context.filesDir, assetName)
        if (file.exists() && file.length() > 0) {
            return file.absolutePath
        }
        try {
            context.assets.open(assetName).use { `is` ->
                FileOutputStream(file).use { os ->
                    val buffer = ByteArray(4 * 1024)
                    var read: Int
                    while (`is`.read(buffer).also { read = it } != -1) {
                        os.write(buffer, 0, read)
                    }
                    os.flush()
                }
                return file.absolutePath
            }
        } catch (e: IOException) {
            Log.e("N", "Error process asset $assetName to file path")
        }
        return null
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == "scanImage") {
                try {
                    val labels: Array<String> = arrayOf("Basal Cell Carcinoma", "Melanoma", "Acne", "Folliculitis", "Pityriasis Rubra Pilaris", "Erythema", "Squamous Cell Carcinoma", "Porokeratosis Actinic", "Pityriasis Rosea", "Hailey Hailey Disease", "Granuloma Annulare", "Prurigo Nodularis")
                    val imagePath = call.arguments as String
                    val image: Bitmap = BitmapFactory.decodeFile(imagePath).scale(224, 224)
                    val model: Module = LiteModuleLoader.load(MainActivity().assetFilePath(getApplicationContext(), "model.ptl"))
                    val normMean: FloatArray = floatArrayOf(0.66386014F, 0.4962325F, 0.42691633F)
                    val normStd: FloatArray = floatArrayOf(0.18904826F, 0.1738958F, 0.17939915F)
                    val inputTensor: Tensor = TensorImageUtils.bitmapToFloat32Tensor(image, normMean, normStd, MemoryFormat.CHANNELS_LAST)
                    val outputTensor: Tensor = model.forward(IValue.from(inputTensor)).toTensor()
                    val scores: FloatArray = outputTensor.dataAsFloatArray
                    var maxScore = -Float.MAX_VALUE
                    var maxScoreIdx: Int = -1
                    for (i in 0 until scores.count()) {
                        if (scores[i] > maxScore) {
                            maxScore = scores[i]
                            maxScoreIdx = i
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
                    map["label"] = labels[maxScoreIdx]
                    map["confidence"] = probabilities[maxScoreIdx]
                    result.success(map)
                } catch (exception: Exception) {
                    result.error(exception.toString(), null, null)
                }
            }
        }
    }
}