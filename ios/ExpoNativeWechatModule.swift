import ExpoModulesCore

public class ExpoNativeWechatModule: Module {
    private let responseHandler = ResponseHandler()
    
    private var appid: String = ""
    
    private var logger = ExpoNativeWechatLogger(prefix: "[Native Wechat]")
    
    private func registerResponder () {
        NotificationCenter.default.addObserver(self, selector: #selector(handleResponse), name: Notification.Name("NativeWechatResponseData"), object: nil)
    }
    
    @objc func handleResponse(data: NSDictionary) {
        var data: [String: Any?] = ExpoWechatUtils.convertToSwiftDictionary(data: data)
        
        sendEvent("NativeWechatResponseData", data)
    }
    
    public func definition() -> ModuleDefinition {
        Name("ExpoNativeWechat")
        
        OnCreate {
            registerResponder()
        }
        
        Constants([
            "WXSceneSession": WXSceneSession,
            "WXSceneTimeline": WXSceneTimeline,
            "WXSceneFavorite": WXSceneFavorite,
            "WXMiniProgramTypeRelease": WXMiniProgramType.release,
            "WXMiniProgramTypeTest": WXMiniProgramType.test,
            "WXMiniProgramTypePreview": WXMiniProgramType.preview,
        ]);
        
        Function("registerApp") {(params: RegisterAppParams) -> Void in
            if(params.log){
                if let logPrefix = params.logPrefix {
                    logger.logPrefix = logPrefix
                }
                
                WXApi.startLog(by: WXLogLevel.detail, logDelegate: logger)
            }
            
            appid = params.appid
            
            WXApi.registerApp(appid, universalLink: params.universalLink)
        }
        
        Events("checkUniversalLinkReadyResp")
        
        Function("checkUniversalLinkReady") {
            WXApi.checkUniversalLinkReady { step, result in
                if result.success {
                    if step == WXULCheckStep.final {
                        self.sendEvent("checkUniversalLinkReadyResp", [
                            "suggestion": "",
                            "errorInfo": ""
                        ])
                    }
                } else {
                    self.sendEvent("checkUniversalLinkReadyResp", [
                        "suggestion": result.suggestion,
                        "errorInfo": result.errorInfo
                    ])
                }
            }
        }
        
        Events("isWechatInstalledResp")
        
        Function("isWechatInstalled") {
            let installed = WXApi.isWXAppInstalled()
            
            sendEvent("isWechatInstalledResp", ["success": installed])
        }
        
        Function("sendAuthRequest") { (params: SendAuthRequestParams) -> Void in
            var req = SendAuthReq()
            
            req.scope = params.scope
            req.state = params.state
            
            WXApi.send(req) { success in
                self.sendEvent("sendAuthRequestResp", ["success": success])
            }
        }
        
        Function("shareText") { (params: ShareTextParams) -> Void in
            var req = SendMessageToWXReq()
            
            req.bText = true
            req.text = params.text
            req.scene = Int32(params.scene)
            
            WXApi.send(req) { success in
                self.sendEvent("shareTextResp", ["success": success])
            }
        }
        
        Function("shareImage") { (params: ShareImageParams) -> Void in
            let url = URL(string: params.src);
            
            ExpoWechatUtils.downloadFile(url: url!) { data in
                guard data != nil else {
                    self.sendEvent("shareImageResp", ["success": false, "message": "Image data is empty"])
                    return
                }
                
                var imageObject = WXImageObject()
                imageObject.imageData = data!
                
                var message = WXMediaMessage()
                message.thumbData = data
                message.mediaObject = imageObject
                
                var req = SendMessageToWXReq()
                req.bText = false
                req.scene = Int32(params.scene)
                req.message = message
                
                WXApi.send(req) { success in
                    self.sendEvent("shareImageResp", ["success": success])
                }
            } onError: { error in
                self.sendEvent("shareImageResp", ["success": false, "message": error?.localizedDescription])
            }
        }
        
        Function("shareVideo") { (params: ShareVideoParams) -> Void in
            var videoObj = WXVideoObject()
            
            videoObj.videoUrl = params.videoUrl
            videoObj.videoLowBandUrl = params.videoLowBandUrl ?? ""
            
            var message = WXMediaMessage()
            
            message.title = params.title ?? ""
            message.description = params.description ?? ""
            message.mediaObject = videoObj
            
            let onCoverDownloaded: ((Data?) -> Void)  = { data in
                if let imgData = data {
                    message.setThumbImage(UIImage(data: imgData)!)
                }
                
                var req = SendMessageToWXReq()
                req.bText = false
                req.message = message
                req.scene = Int32(params.scene)
                
                WXApi.send(req) { success in
                    self.sendEvent("shareVideoResp", ["success": success])
                }
            }
            
            if let coverUrl = params.coverUrl {
                let url = URL(string: params.coverUrl!)
                
                ExpoWechatUtils.downloadFile(url: url!) { data in
                    if data == nil {
                        let compressed = ExpoWechatUtils.compressImage(data: data!, limit: 32000)
                        
                        onCoverDownloaded(compressed)
                    } else{
                        onCoverDownloaded(nil)
                    }
                } onError: { error in
                    self.sendEvent("shareVideoResp", ["success": false, "message": error?.localizedDescription])
                }
                
            } else {
                onCoverDownloaded(nil)
            }
        }
        
        Function("shareWebpage") { (params: ShareWebpageParams) -> Void in
            var webpackObj = WXWebpageObject()
            
            webpackObj.webpageUrl = params.webpageUrl
            
            var message = WXMediaMessage()
            
            message.title = params.title ?? ""
            message.description = params.description ?? ""
            message.mediaObject = webpackObj
            
            let onCoverDownloaded: ((Data?) -> Void)  = { data in
                if let imgData = data {
                    message.setThumbImage(UIImage(data: imgData)!)
                }
                
                var req = SendMessageToWXReq()
                req.bText = false
                req.message = message
                req.scene = Int32(params.scene)
                
                WXApi.send(req) { success in
                    self.sendEvent("shareWebpageResp", ["success": success])
                }
            }
            
            if let coverUrl = params.coverUrl {
                let url = URL(string: params.coverUrl!)
                
                ExpoWechatUtils.downloadFile(url: url!) { data in
                    if data == nil {
                        let compressed = ExpoWechatUtils.compressImage(data: data!, limit: 32000)
                        
                        onCoverDownloaded(compressed)
                    } else{
                        onCoverDownloaded(nil)
                    }
                } onError: { error in
                    self.sendEvent("shareWebpageResp", ["success": false, "message": error?.localizedDescription])
                }
                
            } else {
                onCoverDownloaded(nil)
            }
        }
        
        Function("shareMiniProgram") { (params: ShareMiniProgramParams) -> Void in
            var object = WXMiniProgramObject()
            
            object.userName = params.userName
            object.webpageUrl = params.webpageUrl
            object.path = params.path
            object.withShareTicket = params.withShareTicket ?? false
            object.miniProgramType = switch params.miniProgramType {
            case 0:
                WXMiniProgramType.release
            case 1:
                WXMiniProgramType.test
            case 2:
                WXMiniProgramType.preview
            default:
                WXMiniProgramType.release
            }
            
            var message = WXMediaMessage()
            
            message.title = params.title ?? ""
            message.description = params.description ?? ""
            message.mediaObject = object
            
            let onCoverDownloaded: ((Data?) -> Void)  = { data in
                if let imgData = data {
                    message.setThumbImage(UIImage(data: imgData)!)
                }
                
                var req = SendMessageToWXReq()
                req.bText = false
                req.message = message
                req.scene = 0 // WXSceneSession
                
                WXApi.send(req) { success in
                    self.sendEvent("shareMiniProgramResp", ["success": success])
                }
            }
            
            if let coverUrl = params.coverUrl {
                let url = URL(string: params.coverUrl!)
                
                ExpoWechatUtils.downloadFile(url: url!) { data in
                    if data == nil {
                        let compressed = ExpoWechatUtils.compressImage(data: data!, limit: 32000)
                        
                        onCoverDownloaded(compressed)
                    } else{
                        onCoverDownloaded(nil)
                    }
                } onError: { error in
                    self.sendEvent("shareMiniProgramResp", ["success": false, "message": error?.localizedDescription])
                }
                
            } else {
                onCoverDownloaded(nil)
            }
        }
        
        Function("requestPayment") { (params: RequestPaymentParams) -> Void in
            var request = PayReq()
            
            request.partnerId = params.partnerId
            request.prepayId = params.prepayId
            request.package = "Sign=WXPay"
            request.nonceStr = params.nonceStr
            request.timeStamp = UInt32(params.timeStamp) ?? 0
            request.sign = params.sign

            
            WXApi.send(request) { success in
                self.sendEvent("requestPaymentResp", ["success": success])
            }
        }
    }
}
