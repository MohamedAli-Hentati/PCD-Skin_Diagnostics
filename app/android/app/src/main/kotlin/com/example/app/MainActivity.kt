package com.example.app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import androidx.core.graphics.scale
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.pytorch.IValue
import org.pytorch.LiteModuleLoader
import org.pytorch.MemoryFormat
import org.pytorch.Module
import org.pytorch.Tensor
import org.pytorch.torchvision.TensorImageUtils
import java.io.*


class MainActivity: FlutterActivity() {
    private val CHANNEL = "channel";
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
    fun getPytorchVersion() : String {
        return "2.1.0";
    }
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getPytorchVersion") {
                result.success(getPytorchVersion())
            }
            if (call.method == "classifyImage") {
                try {
                    val classesNames: Array<String> = arrayOf<String>("Acne", "Basal cell carcinoma", "Folliculitis", "Lupus erythematosus", "Pityriasis rubra pilaris", "Squamous cell carcinoma")
                    val filepath = call.arguments as String
                    val bitmap: Bitmap = BitmapFactory.decodeFile(filepath).scale(224, 224)
                    val module: Module = LiteModuleLoader.load(assetFilePath(this, "model.ptl"));
                    val inputTensor: Tensor = TensorImageUtils.bitmapToFloat32Tensor(bitmap, TensorImageUtils.TORCHVISION_NORM_MEAN_RGB, TensorImageUtils.TORCHVISION_NORM_STD_RGB, MemoryFormat.CHANNELS_LAST);
                    val outputTensor: Tensor = module.forward(IValue.from(inputTensor)).toTensor();
                    val scores: FloatArray = outputTensor.getDataAsFloatArray();
                    var maxScore: Float = 0F;
                    var maxScoreIdx: Int = -1;
                    var className = ""
                    for (i in 0 until scores.count()) {
                        className += scores[i].toString() + " "
                        if (scores[i] > maxScore) {
                            maxScore = scores[i]
                            maxScoreIdx = i
                        }
                    }
                    //val className: String = classesNames[maxScoreIdx]
                    result.success(className);
                } catch (exception: Exception) {
                    result.error(exception.toString(), null, null)
                }
            }
        }
    }
}