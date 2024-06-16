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
          if (!response.isSuccessful) throw IOException("Unexpected code $response")

          val bytes = res.body?.bytes()

          if (bytes != null) {
            callback.onResponse(BitmapFactory.decodeByteArray(bytes, 0, bytes.size))
          }
        }
      }
    })
  }

  fun bmpToByteArray(bmp: Bitmap, needRecycle: Boolean): ByteArray {
    var i: Int
    var j: Int
    if (bmp.height > bmp.width) {
      i = bmp.width
      j = bmp.width
    } else {
      i = bmp.height
      j = bmp.height
    }

    val localBitmap = Bitmap.createBitmap(i, j, Bitmap.Config.RGB_565)
    val localCanvas = Canvas(localBitmap)

    while (true) {
      localCanvas.drawBitmap(bmp, Rect(0, 0, i, j), Rect(0, 0, i, j), null)
      if (needRecycle) bmp.recycle()
      val localByteArrayOutputStream = ByteArrayOutputStream()
      localBitmap.compress(
        Bitmap.CompressFormat.JPEG, 100,
        localByteArrayOutputStream
      )
      localBitmap.recycle()
      val arrayOfByte = localByteArrayOutputStream.toByteArray()
      try {
        localByteArrayOutputStream.close()
        return arrayOfByte
      } catch (e: Exception) {
        //F.out(e);
      }
      i = bmp.height
      j = bmp.height
    }
  }

  fun compressImage(image: Bitmap, size: Int): Bitmap? {
    val baos = ByteArrayOutputStream()
    image.compress(Bitmap.CompressFormat.JPEG, 100, baos)
    var options = 100

    while (baos.toByteArray().size / 1024 > size) {
      // 重置baos即清空baos
      baos.reset()
      if (options > 10) {
        options -= 8
      } else {
        return compressImage(
          Bitmap.createScaledBitmap(
            image,
            280,
            image.height / image.width * 280,
            true
          ), size
        )
      }
      // 这里压缩options%，把压缩后的数据存放到baos中
      image.compress(Bitmap.CompressFormat.JPEG, options, baos)
    }

    val isBm = ByteArrayInputStream(baos.toByteArray())
    val newBitmap = BitmapFactory.decodeStream(isBm, null, null)

    return newBitmap
  }

  interface DownloadBitmapCallback {
    fun onFailure(call: Call, e: IOException)

    fun onResponse(bitmap: Bitmap)
  }
}
