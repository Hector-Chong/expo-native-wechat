//
//  RespDataHelper.swift
//  ExpoNativeWechat
//
//  Created by Hector Chong on 4/2/24.
//

import Foundation

@objc public class RespDataHelper: NSObject{
    @objc public static func downcastRepo(baseResp: BaseResp) -> NSDictionary {
        var dictionary = NSMutableDictionary();
        
        if baseResp.errCode == 0 {
            if baseResp.isKind(of: SendAuthResp.self) {
                let sendAuthResp = baseResp as! SendAuthResp;
                
                dictionary.setValue(sendAuthResp.code, forKey: "code");
                dictionary.setValue(sendAuthResp.state, forKey: "state");
                
                if let lang = sendAuthResp.lang {
                    dictionary.setValue(lang, forKey: "lang");
                }
                
                if let country = sendAuthResp.country {
                    dictionary.setValue(country, forKey: "country");
                }
            }
            
            if baseResp.isKind(of: WXLaunchMiniProgramResp.self) {
                let resp = baseResp as! WXLaunchMiniProgramResp;
                
                dictionary.setValue(resp.extMsg, forKey: "extMsg");
            }
        }
        
        return wrapperResponse(baseResp: baseResp, data: dictionary);
    }
    
    @objc public static func wrapperResponse(baseResp: BaseResp, data: NSMutableDictionary) -> NSDictionary {
        let dictionary: NSDictionary = [
            "type": NSStringFromClass(type(of: baseResp)),
            "errorCode": baseResp.errCode,
            "errorStr": baseResp.errStr,
            "data": data
        ];
        
        return dictionary
    }
}
