package expo.modules.nativewechat

import android.os.Bundle
import androidx.core.os.bundleOf
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.modelmsg.SendAuth

object NativeWechatRespDataHelper {
  private var type: String = ""

  fun downcastResp(baseResp: BaseResp?): Bundle {
    if (baseResp == null)
      return bundleOf()

    if (baseResp.errCode == 0) {
      if (baseResp is SendAuth.Resp) {
        type = "SendAuthResp"
        val resp: SendAuth.Resp = baseResp

        val argument = bundleOf(
          "code" to resp.code,
          "state" to resp.state,
          "lang" to resp.lang,
          "country" to resp.country,
        )

        return wrapResponse(baseResp, argument)
      }
    }

    return bundleOf()
  }

  private fun wrapResponse(
    baseResp: BaseResp,
    data: Bundle
  ): Bundle {
    return bundleOf(
      "type" to type,
      "errorCode" to baseResp.errCode,
      "errorStr" to baseResp.errStr,
      "transaction" to baseResp.transaction,
      "data" to data
    )
  }
}
