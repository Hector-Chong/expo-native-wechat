//
//  ResponseHandler.m
//  ExpoNativeWechat
//
//  Created by Hector Chong on 4/8/24.
//

#import "ResponseHandler.h"
#import "RespDataHelper.h"

@implementation ResponseHandler

- (void)onResp:(BaseResp *)resp {
    
    NSDictionary* convertedData = [RespDataHelper downcastResp:resp];
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center postNotificationName:@"ResponseData" object:nil userInfo:convertedData];
}

@end
