package expo.modules.nativewechat

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.os.bundleOf
import com.tencent.mm.opensdk.modelbase.BaseReq
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.modelbiz.SubscribeMessage
import com.tencent.mm.opensdk.modelbiz.WXLaunchMiniProgram
import com.tencent.mm.opensdk.modelbiz.WXOpenCustomerServiceChat
import com.tencent.mm.opensdk.modelmsg.SendAuth
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX
import com.tencent.mm.opensdk.modelmsg.WXImageObject
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage
import com.tencent.mm.opensdk.modelmsg.WXMiniProgramObject
import com.tencent.mm.opensdk.modelmsg.WXTextObject
import com.tencent.mm.opensdk.modelmsg.WXVideoObject
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject
import com.tencent.mm.opensdk.modelpay.PayReq
import com.tencent.mm.opensdk.openapi.IWXAPI
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler
import com.tencent.mm.opensdk.openapi.WXAPIFactory
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import expo.modules.nativewechat.ExpoNativeWechatUtils.DownloadBitmapCallback
import okhttp3.Call
import java.io.IOException


class ExpoNativeWechatModule : Module(), IWXAPIEventHandler {
  private var appid: String? = null
  private var registered = false
  private var wxApi: IWXAPI? = null
  private val REDIRECT_INTENT_ACTION = "com.hector.nativewechat.ACTION_REDIRECT_INTENT"
  private val reactContext
    get() = requireNotNull(appContext.reactContext)

  @RequiresApi(Build.VERSION_CODES.O)
  override fun definition() = ModuleDefinition {
    Name("ExpoNativeWechat")

    Function("getConstants") {
      return@Function bundleOf(
        "WXSceneSession" to SendMessageToWX.Req.WXSceneSession,
        "WXSceneTimeline" to SendMessageToWX.Req.WXSceneTimeline,
        "WXSceneFavorite" to SendMessageToWX.Req.WXSceneFavorite,
        "WXMiniProgramTypeRelease" to WXLaunchMiniProgram.Req.MINIPTOGRAM_TYPE_RELEASE,
        "WXMiniProgramTypeTest" to WXLaunchMiniProgram.Req.MINIPROGRAM_TYPE_TEST,
        "WXMiniProgramTypePreview" to WXLaunchMiniProgram.Req.MINIPROGRAM_TYPE_PREVIEW
      )
    }

    Events("ResponseData", "ResponseFromNotification")

    Function("registerApp") { params: RegisterAppParams ->
      appid = params.appid
      registered = true

      wxApi = WXAPIFactory.createWXAPI(reactContext, appid, true);

      val success = wxApi?.registerApp(appid)

      appContext.reactContext?.registerReceiver(object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
          handleIntent(intent.extras!!["intent"] as Intent?)
        }
      }, IntentFilter(REDIRECT_INTENT_ACTION), Context.RECEIVER_EXPORTED);

      this@ExpoNativeWechatModule.sendEvent(
        "ResponseData", bundleOf(
          "success" to success,
          "id" to params.id
        )
      )
    }

    Function("isWechatInstalled") { params: BasicRequestParams ->
      val installed = wxApi?.isWXAppInstalled()

      this@ExpoNativeWechatModule.sendEvent(
        "ResponseData", bundleOf(
          "success" to installed,
          "id" to params.id
        )
      )
    }

    Function("sendAuthRequest") { params: SendAuthRequestParams ->
      var req = SendAuth.Req()

      req.scope = params.scope
      req.state = req.state

      sendEvent(
        "ResponseData", bundleOf(
          "id" to params.id,
          "success" to wxApi?.sendReq(req)
        )
      )
    }

    Function("shareText") { params: ShareTextParams ->
      val text = params.text
      val scene = params.scene

      val textObj = WXTextObject()
      textObj.text = text

      val msg = WXMediaMessage()
      msg.mediaObject = textObj
      msg.description = text

      val req = SendMessageToWX.Req()
      req.message = msg
      req.scene = scene

      sendEvent(
        "ResponseData", bundleOf(
          "id" to params.id,
          "success" to wxApi?.sendReq(req)
        )
      )
    }

    Function("shareWebpage") { params: ShareWebpageParams ->
      val webpageUrl = params.webpageUrl
      val title = params.title
      val description = params.description
      val coverUrl = params.coverUrl
      val scene = params.scene

      val webpageObj = WXWebpageObject()
      webpageObj.webpageUrl = webpageUrl

      val msg = WXMediaMessage(webpageObj)
      msg.title = title
      msg.description = description

      val onCoverDownloaded: (Bitmap?) -> Unit = { bitmap ->
        bitmap?.let {
          msg.thumbData = ExpoNativeWechatUtils.bmpToByteArray(bitmap, 32, true)
        }

        val req = SendMessageToWX.Req()
        req.message = msg
        req.scene = scene

        sendEvent(
          "ResponseData", bundleOf(
            "id" to params.id,
            "success" to wxApi?.sendReq(req)
          )
        )
      }

      if (!coverUrl.isNullOrEmpty()) {
        ExpoNativeWechatUtils.downloadFileAsBitmap(coverUrl, object : DownloadBitmapCallback {
          override fun onFailure(call: Call, e: IOException) {
            this@ExpoNativeWechatModule.sendEvent(
              "ResponseData", bundleOf(
                "id" to params.id,
                "success" to false,
                "message" to e.localizedMessage
              )
            )
          }

          override fun onResponse(bitmap: Bitmap) {
            onCoverDownloaded(bitmap)
          }
        })
      } else {
        onCoverDownloaded(null)
      }
    }

    Function("shareVideo") { params: ShareVideoParams ->
      val videoUrl = params.videoUrl
      val videoLowBandUrl = params.videoLowBandUrl
      val title = params.title
      val description = params.description
      val coverUrl = params.coverUrl
      val scene = params.scene

      val video = WXVideoObject()
      video.videoUrl = videoUrl

      if (videoLowBandUrl != null) video.videoLowBandUrl = videoLowBandUrl

      val msg = WXMediaMessage(video)
      msg.title = title
      msg.description = description

      val onCoverDownloaded: (Bitmap?) -> Unit = { bitmap ->
        bitmap?.let {
          msg.thumbData = ExpoNativeWechatUtils.bmpToByteArray(bitmap, 32, true)
        }

        val req = SendMessageToWX.Req()
        req.message = msg
        req.scene = scene

        sendEvent(
          "ResponseData", bundleOf(
            "id" to params.id,
            "success" to wxApi?.sendReq(req)
          )
        )
      }

      if (!coverUrl.isNullOrEmpty()) {
        ExpoNativeWechatUtils.downloadFileAsBitmap(coverUrl, object : DownloadBitmapCallback {
          override fun onFailure(call: Call, e: IOException) {
            this@ExpoNativeWechatModule.sendEvent(
              "ResponseData", bundleOf(
                "id" to params.id,
                "success" to false,
                "message" to e.localizedMessage
              )
            )
          }

          override fun onResponse(bitmap: Bitmap) {
            onCoverDownloaded(bitmap)
          }
        })
      } else {
        onCoverDownloaded(null)
      }
    }

    Function("shareMiniProgram") { params: ShareMiniProgramParams ->
      val webpageUrl = params.webpageUrl
      val userName = params.userName
      val path = params.path
      val title = params.title
      val description = params.description
      val coverUrl = params.coverUrl
      val withShareTicket = params.withShareTicket
      val miniProgramType = params.miniProgramType
      val scene = params.scene

      val miniProgramObj = WXMiniProgramObject()
      miniProgramObj.webpageUrl = webpageUrl
      miniProgramObj.miniprogramType = miniProgramType
      miniProgramObj.userName = userName
      miniProgramObj.path = path
      miniProgramObj.withShareTicket = withShareTicket!!

      val msg = WXMediaMessage(miniProgramObj)
      msg.title = title
      msg.description = description

      val onCoverDownloaded: (Bitmap?) -> Unit = { bitmap ->
        bitmap?.let {
          msg.thumbData = ExpoNativeWechatUtils.bmpToByteArray(bitmap, 32, true)
        }

        val req = SendMessageToWX.Req()
        req.message = msg
        req.scene = scene

        sendEvent(
          "ResponseData", bundleOf(
            "id" to params.id,
            "success" to wxApi?.sendReq(req)
          )
        )
      }

      if (!coverUrl.isNullOrEmpty()) {
        ExpoNativeWechatUtils.downloadFileAsBitmap(coverUrl, object : DownloadBitmapCallback {
          override fun onFailure(call: Call, e: IOException) {
            this@ExpoNativeWechatModule.sendEvent(
              "ResponseData", bundleOf(
                "id" to params.id,
                "success" to false,
                "message" to e.localizedMessage
              )
            )
          }

          override fun onResponse(bitmap: Bitmap) {
            onCoverDownloaded(bitmap)
          }
        })
      } else {
        onCoverDownloaded(null)
      }
    }

    Function("requestPayment") { params: RequestPaymentParams ->
      val payReq = PayReq()

      payReq.partnerId = params.partnerId
      payReq.prepayId = params.prepayId
      payReq.nonceStr = params.nonceStr
      payReq.timeStamp = params.timeStamp
      payReq.sign = params.sign
      payReq.packageValue = "Sign=WXPay"
      payReq.extData = params.extData
      payReq.appId = appid

      sendEvent(
        "ResponseData", bundleOf(
          "id" to params.id,
          "success" to wxApi?.sendReq(payReq)
        )
      )
    }

    Function("requestSubscribeMessage") { params: RequestSubscribeMsgParams ->
      val templateId = params.templateId
      val reserved = params.reserved
      val scene = params.scene

      val req = SubscribeMessage.Req()
      req.scene = scene;
      req.templateID = templateId;
      req.reserved = reserved;

      sendEvent(
        "ResponseData", bundleOf(
          "id" to params.id,
          "success" to wxApi?.sendReq(req)
        )
      )
    }

    Function("launchMiniProgram") { params: LaunchMiniprogramParams ->
      val userName = params.userName
      val path = params.path
      val miniProgramType = params.miniProgramType

      val req = WXLaunchMiniProgram.Req()
      req.userName = userName;
      req.path = path;
      req.miniprogramType = miniProgramType;

      sendEvent(
        "ResponseData", bundleOf(
          "id" to params.id,
          "success" to wxApi?.sendReq(req)
        )
      )
    }

    Function("openCustomerService") { params: OpenCustomerServiceParams ->
      val corpId = params.corpid
      val url = params.url

      val req = WXOpenCustomerServiceChat.Req()
      req.corpId = corpId
      req.url = url

      sendEvent(
        "ResponseData", bundleOf(
          "id" to params.id,
          "success" to wxApi?.sendReq(req)
        )
      )
    }

  }

  fun handleIntent(intent: Intent?) {
    wxApi!!.handleIntent(intent, this)
  }

  override fun onReq(req: BaseReq?) {}

  override fun onResp(baseResp: BaseResp?) {
    val convertedData = NativeWechatRespDataHelper.downcastResp(baseResp)

    sendEvent("ResponseFromNotification", convertedData)
  }

}
