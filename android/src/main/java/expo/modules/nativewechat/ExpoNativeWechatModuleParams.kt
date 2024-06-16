package expo.modules.nativewechat

import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class BasicRequestParams : Record {
  @Field
  val id: String = ""
}

class RegisterAppParams : Record {
  @Field
  val id: String = ""

  @Field
  val log: Boolean = false

  @Field
  val appid: String = ""

  @Field
  val logPrefix: String? = null

  @Field
  val universalLink: String = ""
}

class SendAuthRequestParams : Record {
  @Field
  val id: String = ""

  @Field
  val state: String = ""

  @Field
  val scope: String? = null
}


class ShareTextParams : Record {
  @Field
  val id: String = ""

  @Field
  val text: String = ""

  @Field
  val scene: Int = 0
}


class ShareImageParams : Record {
  @Field
  val id: String = ""

  @Field
  val src: String = ""

  @Field
  val scene: Int = 0
}

class ShareVideoParams : Record {
  @Field
  val id: String = ""

  @Field
  val videoUrl: String = ""

  @Field
  val title: String? = null

  @Field
  val description: String? = null

  @Field
  val videoLowBandUrl: String? = null

  @Field
  val coverUrl: String? = null

  @Field
  val scene: Int = 0
}

class ShareWebpageParams : Record {
  @Field
  val id: String = ""

  @Field
  val webpageUrl: String = ""

  @Field
  val title: String? = null

  @Field
  val description: String? = null

  @Field
  val coverUrl: String? = null

  @Field
  val scene: Int = 0
}

class ShareMiniProgramParams : Record {
  @Field
  val id: String = ""

  @Field
  val userName: String = ""

  @Field
  val miniProgramType: Int = 0

  @Field
  val webpageUrl: String = ""

  @Field
  val path: String = ""

  @Field
  val withShareTicket: Boolean? = null

  @Field
  val title: String? = null

  @Field
  val description: String? = null

  @Field
  val coverUrl: String? = null

  @Field
  val scene: Int = 0
}

class RequestPaymentParams : Record {
  @Field
  val id: String = ""

  @Field
  val partnerId: String = ""

  @Field
  val nonceStr: String = ""

  @Field
  val prepayId: String = ""

  @Field
  val timeStamp: String = ""

  @Field
  val sign: String = ""

  @Field
  val extData: String = ""
}

class RequestSubscribeMsgParams : Record {
  @Field
  val id: String = ""

  @Field
  val scene: Int = 0

  @Field
  val templateId: String = ""

  @Field
  val reserved: String? = null
}

class LaunchMiniprogramParams : Record {
  @Field
  val id: String = ""

  @Field
  val userName: String = ""

  @Field
  val path: String = ""

  @Field
  val miniProgramType: Int = 0
}

class OpenCustomerServiceParams : Record {
  @Field
  val id: String = ""

  @Field
  val corpid: String = ""

  @Field
  val url: String = ""
}
