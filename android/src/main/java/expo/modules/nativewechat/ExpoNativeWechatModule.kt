package expo.modules.nativewechat

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.core.os.bundleOf
import com.tencent.mm.opensdk.modelbase.BaseReq
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.modelbiz.WXLaunchMiniProgram
import com.tencent.mm.opensdk.modelmsg.SendAuth
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX
import com.tencent.mm.opensdk.openapi.IWXAPI
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler
import com.tencent.mm.opensdk.openapi.WXAPIFactory
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition


class ExpoNativeWechatModule : Module(), IWXAPIEventHandler {
  private var appid: String? = null
  private var registered = false
  private var wxApi: IWXAPI? = null
  private val REDIRECT_INTENT_ACTION = "com.hector.nativewechat.ACTION_REDIRECT_INTENT"
  private val reactContext
    get() = requireNotNull(appContext.reactContext)

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
      }, IntentFilter(REDIRECT_INTENT_ACTION));

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
