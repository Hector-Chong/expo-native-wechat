//
//  ExpoNativeWechatModuleParams.swift
//  ExpoNativeWechat
//
//  Created by Hector Chong on 4/7/24.
//

import ExpoModulesCore

struct BasicRequestParams: Record {
    @Field
    var id: String
}

struct RegisterAppParams: Record {
    @Field
    var id: String
    
    @Field
    var log: Bool = false
    
    @Field
    var appid: String
    
    @Field
    var logPrefix: String?
    
    @Field
    var universalLink: String
}

struct SendAuthRequestParams: Record {
    @Field
    var id: String
    
    @Field
    var state: String
    
    @Field
    var scope: String?
}


struct ShareTextParams: Record {
    @Field
    var id: String
    
    @Field
    var text: String
    
    @Field
    var scene: Int
}


struct ShareImageParams: Record {
    @Field
    var id: String
    
    @Field
    var src: String
    
    @Field
    var scene: Int
}

struct ShareVideoParams: Record {
    @Field
    var id: String
    
    @Field
    var videoUrl: String
    
    @Field
    var title: String?
    
    @Field
    var description: String?
    
    @Field
    var videoLowBandUrl: String?
    
    @Field
    var coverUrl: String?
    
    @Field
    var scene: Int
}

struct ShareWebpageParams: Record {
    @Field
    var id: String
    
    @Field
    var webpageUrl: String
    
    @Field
    var title: String?
    
    @Field
    var description: String?
    
    @Field
    var coverUrl: String?
    
    @Field
    var scene: Int
}

struct ShareMiniProgramParams: Record {
    @Field
    var id: String
    
    @Field
    var userName: String
    
    @Field
    var miniProgramType: Int
    
    @Field
    var webpageUrl: String
    
    @Field
    var path: String
    
    @Field
    var withShareTicket: Bool?
    
    @Field
    var title: String?
    
    @Field
    var description: String?
    
    @Field
    var coverUrl: String?
}

struct RequestPaymentParams: Record {
    @Field
    var id: String
    
    @Field
    var partnerId: String
    
    @Field
    var nonceStr: String
    
    @Field
    var prepayId: String
    
    @Field
    var timeStamp: String
    
    @Field
    var sign: String
}

struct RequestSubscribeMsgParams: Record {
    @Field
    var id: String
    
    @Field
    var scene: Int
    
    @Field
    var templateId: String
    
    @Field
    var reserved: String?
}

struct LaunchMiniprogramParams: Record {
    @Field
    var id: String
    
    @Field
    var userName: String
    
    @Field
    var path: String
    
    @Field
    var miniProgramType: Int
}

struct OpenCustomerServiceParams: Record {
    @Field
    var id: String
    
    @Field
    var corpid: String
    
    @Field
    var url: String
}
