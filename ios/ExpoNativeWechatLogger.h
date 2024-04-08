//
//  ExpoNativeWechatLogger.h
//  Pods
//
//  Created by Hector Chong on 4/7/24.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface ExpoNativeWechatLogger : NSObject<WXApiLogDelegate>

@property (nonatomic, nonnull) NSString* logPrefix;

- (nonnull instancetype)initWithPrefix:(nonnull NSString *) prefix;

@end
