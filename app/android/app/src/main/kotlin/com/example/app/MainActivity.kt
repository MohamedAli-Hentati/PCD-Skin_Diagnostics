package com.example.app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import androidx.core.graphics.scale
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.pytorch.*
import org.pytorch.torchvision.*
import java.io.*


class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.android/channel";
    @Throws(IOException::class)
    fun assetFilePath(context: Context, assetName: String?): String? {
        val file = File(context.filesDir, assetName)
        if (file.exists() && file.length() > 0) {
            return file.absolutePath
        }
        context.assets.open(assetName!!).use { `is` ->
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
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "scanImage") {
                try {
                    val classesNames: Array<String> = arrayOf<String>("Acne", "Basal cell carcinoma", "Folliculitis", "Lupus erythematosus", "Pityriasis rubra pilaris", "Squamous cell carcinoma")
                    val filepath = call.arguments as String
                    val bitmap: Bitmap = BitmapFactory.decodeFile(filepath).scale(224, 224)
                    val module: Module = Module.load(assetFilePath(this, "model.pt"));
                    val normMean: FloatArray = floatArrayOf(0.6286657F, 0.46822867F, 0.41442943F)
                    val normStd: FloatArray = floatArrayOf(0.21822813F, 0.19549523F, 0.20002359F)
                    val inputTensor: Tensor = TensorImageUtils.bitmapToFloat32Tensor(bitmap, normMean, normStd, MemoryFormat.CHANNELS_LAST);
                    val outputTensor: Tensor = module.forward(IValue.from(inputTensor)).toTensor();
                    val scores: FloatArray = outputTensor.getDataAsFloatArray();
                    var maxScore = 0F;
                    var maxScoreIdx: Int = -1;
                    for (i in 0 until scores.count()) {
                        if (scores[i] > maxScore) {
                            maxScore = scores[i]
                            maxScoreIdx = i
                        }
                    }
                    val className: String = classesNames[maxScoreIdx]
                    result.success(className);
                } catch (exception: Exception) {
                    result.error(exception.toString(), null, null)
                }
            }
        }
    }
}