import ExpoModulesCore

public class ExpoNativeWechatModule: Module {
    private var appid: String = ""
    
    private var logger = ExpoNativeWechatLogger(prefix: "[Native Wechat]")
    
    private func registerResponder () {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleResponse),
            name: Notification.Name("ResponseData"),
            object: nil
        )
    }
    
    @objc func handleResponse(_ notification: Notification) {
        let data = notification.userInfo as! [String : Any]
        
        sendEvent("ResponseFromNotification", data)
    }
    
    public func definition() -> ModuleDefinition {
        Name("ExpoNativeWechat")
        
        OnCreate {
            registerResponder()
        }
        
        Events("ResponseData")
        Events("ResponseFromNotification")
        
        Function("getConstants") {
            return [
                "WXSceneSession": WXSceneSession.rawValue,
                "WXSceneTimeline": WXSceneTimeline.rawValue,
                "WXSceneFavorite": WXSceneFavorite.rawValue,
                "WXMiniProgramTypeRelease": WXMiniProgramType.release.rawValue,
                "WXMiniProgramTypeTest": WXMiniProgramType.test.rawValue,
                "WXMiniProgramTypePreview": WXMiniProgramType.preview.rawValue,
            ]
        }
        
        Function("registerApp") {(params: RegisterAppParams) -> Void in
            if(params.log){
                if let logPrefix = params.logPrefix {
                    logger.logPrefix = logPrefix
                }
                
                WXApi.startLog(by: WXLogLevel.detail, logDelegate: logger)
            }
            
            appid = params.appid
            
            let success = WXApi.registerApp(appid, universalLink: params.universalLink)
            
            sendEvent("ResponseData", ["success": success, "id": params.id])
        }
        
        Function("checkUniversalLinkReady") { (params: BasicRequestParams) -> Void in
            WXApi.checkUniversalLinkReady { step, result in
                if result.success {
                    if step == WXULCheckStep.final {
                        self.sendEvent("ResponseData", [
                            "id": params.id,
                            "success": true,
                            "suggestion": "",
                            "errorInfo": ""
                        ])
                    }
                } else {
                    self.sendEvent("ResponseData", [
                        "id": params.id,
                        "success": true,
                        "suggestion": result.suggestion,
                        "errorInfo": result.errorInfo
                    ])
                }
            }
        }
        
        Function("isWechatInstalled") { (params: BasicRequestParams) -> Void in
            let installed = WXApi.isWXAppInstalled()
            
            sendEvent("ResponseData", ["success": installed, "id": params.id])
        }
        
        Function("sendAuthRequest") { (params: SendAuthRequestParams) -> Void in
            let req = SendAuthReq()
            
            if let scope = params.scope {
                req.scope = scope
            }
            
            req.state = params.state
            
            WXApi.send(req) { success in
                self.sendEvent("ResponseData", ["success": success, "id": params.id])
            }
        }
        
        Function("shareText") { (params: ShareTextParams) -> Void in
            let req = SendMessageToWXReq()
            
            req.bText = true
            req.text = params.text
            req.scene = Int32(params.scene)
            
            WXApi.send(req) { success in
                self.sendEvent("ResponseData", ["success": success, "id": params.id])
            }
        }
        
        Function("shareImage") { (params: ShareImageParams) -> Void in
            let url = URL(string: params.src);
            
            ExpoWechatUtils.downloadFile(url: url!) { data in
                guard data != nil else {
                    self.sendEvent("ResponseData", ["success": false, "id": params.id, "message": "Image data is empty"])
                    return
                }
                
                let imageObject = WXImageObject()
                imageObject.imageData = data!
                
                let message = WXMediaMessage()
                message.thumbData = data
                message.mediaObject = imageObject
                
                let req = SendMessageToWXReq()
                req.bText = false
                req.scene = Int32(params.scene)
                req.message = message
                
                WXApi.send(req) { success in
                    self.sendEvent("ResponseData", ["success": success, "id": params.id])
                }
            } onError: { error in
                self.sendEvent("ResponseData", ["success": false, "message": error?.localizedDescription])
            }
        }
        
        Function("shareVideo") { (params: ShareVideoParams) -> Void in
            let videoObj = WXVideoObject()
            
            videoObj.videoUrl = params.videoUrl
            videoObj.videoLowBandUrl = params.videoLowBandUrl ?? ""
            
            let message = WXMediaMessage()
            
            message.title = params.title ?? ""
            message.description = params.description ?? ""
            message.mediaObject = videoObj
            
            let onCoverDownloaded: ((Data?) -> Void)  = { data in
                if let imgData = data {
                    message.setThumbImage(UIImage(data: imgData)!)
                }
                
                let req = SendMessageToWXReq()
                req.bText = false
                req.message = message
                req.scene = Int32(params.scene)
                
                WXApi.send(req) { success in
                    self.sendEvent("ResponseData", ["success": success, "id": params.id])
                }
            }
            
            if params.coverUrl != nil {
                let url = URL(string: params.coverUrl!)
                
                ExpoWechatUtils.downloadFile(url: url!) { data in
                    if data == nil {
                        let compressed = ExpoWechatUtils.compressImage(data: data!, limit: 32000)
                        
                        onCoverDownloaded(compressed)
                    } else{
                        onCoverDownloaded(nil)
                    }
                } onError: { error in
                    self.sendEvent("ResponseData", ["id": params.id, "success": false, "message": error?.localizedDescription])
                }
                
            } else {
                onCoverDownloaded(nil)
            }
        }
        
        Function("shareWebpage") { (params: ShareWebpageParams) -> Void in
            let webpackObj = WXWebpageObject()
            
            webpackObj.webpageUrl = params.webpageUrl
            
            let message = WXMediaMessage()
            
            message.title = params.title ?? ""
            message.description = params.description ?? ""
            message.mediaObject = webpackObj
            
            let onCoverDownloaded: ((Data?) -> Void)  = { data in
                if let imgData = data {
                    message.setThumbImage(UIImage(data: imgData)!)
                }
                
                let req = SendMessageToWXReq()
                req.bText = false
                req.message = message
                req.scene = Int32(params.scene)
                
                WXApi.send(req) { success in
                    self.sendEvent("ResponseData", ["id": params.id, "success": success])
                }
            }
            
            if params.coverUrl != nil {
                let url = URL(string: params.coverUrl!)
                
                ExpoWechatUtils.downloadFile(url: url!) { data in
                    if data == nil {
                        let compressed = ExpoWechatUtils.compressImage(data: data!, limit: 32000)
                        
                        onCoverDownloaded(compressed)
                    } else{
                        onCoverDownloaded(nil)
                    }
                } onError: { error in
                    self.sendEvent("ResponseData", ["id": params.id, "success": false, "message": error?.localizedDescription])
                }
                
            } else {
                onCoverDownloaded(nil)
            }
        }
        
        Function("shareMiniProgram") { (params: ShareMiniProgramParams) -> Void in
            let object = WXMiniProgramObject()
            
            object.userName = params.userName
            object.webpageUrl = params.webpageUrl
            object.path = params.path
            object.withShareTicket = params.withShareTicket ?? false
            object.miniProgramType = WXMiniProgramType(rawValue: UInt(params.miniProgramType))!
            
            let message = WXMediaMessage()
            
            message.title = params.title ?? ""
            message.description = params.description ?? ""
            message.mediaObject = object
            
            let onCoverDownloaded: ((Data?) -> Void)  = { data in
                if let imgData = data {
                    message.setThumbImage(UIImage(data: imgData)!)
                }
                
                let req = SendMessageToWXReq()
                req.bText = false
                req.message = message
                req.scene = 0 // WXSceneSession
                
                WXApi.send(req) { success in
                    self.sendEvent("ResponseData", ["id": params.id, "success": success])
                }
            }
            
            if params.coverUrl != nil {
                let url = URL(string: params.coverUrl!)
                
                ExpoWechatUtils.downloadFile(url: url!) { data in
                    if data == nil {
                        let compressed = ExpoWechatUtils.compressImage(data: data!, limit: 32000)
                        
                        onCoverDownloaded(compressed)
                    } else{
                        onCoverDownloaded(nil)
                    }
                } onError: { error in
                    self.sendEvent("ResponseData", ["id": params.id, "success": false, "message": error?.localizedDescription])
                }
                
            } else {
                onCoverDownloaded(nil)
            }
        }
        
        Function("requestPayment") { (params: RequestPaymentParams) -> Void in
            let request = PayReq()
            
            request.partnerId = params.partnerId
            request.prepayId = params.prepayId
            request.package = "Sign=WXPay"
            request.nonceStr = params.nonceStr
            request.timeStamp = UInt32(params.timeStamp) ?? 0
            request.sign = params.sign
            
            
            WXApi.send(request) { success in
                self.sendEvent("ResponseData", ["id": params.id, "success": success])
            }
        }
        
        Function("requestSubscribeMessage") { (params: RequestSubscribeMsgParams) -> Void in
            var req = WXSubscribeMsgReq()
            
            req.scene = UInt32(params.scene)
            req.templateId = params.templateId
            req.reserved = params.reserved
            
            WXApi.send(req) { success in
                self.sendEvent("ResponseData", ["id": params.id, "success": success])
            }
        }
        
        Function("launchMiniProgram") { (params: LaunchMiniprogramParams) -> Void in
            var req = WXLaunchMiniProgramReq()
            
            req.userName = params.userName
            req.path = params.path
            req.miniProgramType = WXMiniProgramType(rawValue: UInt(UInt32(params.miniProgramType)))!
            
            WXApi.send(req) { success in
                self.sendEvent("ResponseData", ["id": params.id, "success": success])
            }
        }

        Function("openCustomerService") { (params: OpenCustomerServiceParams) -> Void in
            var req = WXOpenCustomerServiceReq()
            
            req.corpid = params.corpid
            req.url = params.url
            
            WXApi.send(req) { success in
                self.sendEvent("ResponseData", ["id": params.id, "success": success])
            }
        }
    }
}
