//
//  ExpoNativeWechatLogger.m
//  ExpoNativeWechat
//
//  Created by Hector Chong on 4/7/24.
//

#import "ExpoNativeWechatLogger.h"

@implementation ExpoNativeWechatLogger

- (instancetype)initWithPrefix:(NSString *)prefix {
    self = [self init];
    
    if(self){
        _logPrefix = prefix;
    }
    
    return self;
}

- (void)onLog:(nonnull NSString *)log logLevel:(WXLogLevel)level {
    NSLog([NSString stringWithFormat:@"%@%@: ", _logPrefix, @" %@"], log);
}

@end
