//
//  ResponseHandler.m
//  ExpoNativeWechat
//
//  Created by Hector Chong on 4/8/24.
//

#import "ResponseHandler.h"

@implementation ResponseHandler

- (void)onResp:(BaseResp *)resp {
    
    NSDictionary* convertedData = [RespDataHelper downcastRepoWithBaseResp:resp];
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center postNotificationName:@"NativeWechatResponseData" object:nil userInfo:convertedData];
}

@end
