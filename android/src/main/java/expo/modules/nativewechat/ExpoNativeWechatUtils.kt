package expo.modules.nativewechat

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Rect
import okhttp3.Call
import okhttp3.Callback
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.IOException

object ExpoNativeWechatUtils {
  private val client = OkHttpClient()

  public fun downloadFileAsBitmap(url: String, callback: DownloadBitmapCallback) {
    val request = Request.Builder().url(url).build()

    client.newCall(request).enqueue(object : Callback {
      override fun onFailure(call: Call, e: IOException) {
        callback.onFailure(call, e)
      }

      override fun onResponse(call: Call, response: Response) {
        response.use { res ->
          if (!response.isSuccessful) {
            callback.onFailure(call, IOException("Unexpected code $response"));
          } else {
            val bytes = res.body?.bytes()

            if (bytes != null) {
              callback.onResponse(BitmapFactory.decodeByteArray(bytes, 0, bytes.size))
            }
          }
        }
      }
    })
  }

  fun bmpToByteArray(bmp: Bitmap, size: Int, needRecycle: Boolean): ByteArray {
    val outputStream = ByteArrayOutputStream()
    bmp.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);

    var quality = 100

    while (outputStream.toByteArray().size / 1024 > size && quality != 4) {
      outputStream.reset();

      bmp.compress(Bitmap.CompressFormat.JPEG, quality, outputStream);

      quality -= 4;
    }

    if (needRecycle) bmp.recycle()

    return outputStream.toByteArray()
  }

  interface DownloadBitmapCallback {
    fun onFailure(call: Call, e: IOException)

    fun onResponse(bitmap: Bitmap)
  }
}
