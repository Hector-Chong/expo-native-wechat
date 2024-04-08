#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface RespDataHelper: NSObject

+ (NSDictionary *)downcastResp: (BaseResp *)baseResp;

@end
