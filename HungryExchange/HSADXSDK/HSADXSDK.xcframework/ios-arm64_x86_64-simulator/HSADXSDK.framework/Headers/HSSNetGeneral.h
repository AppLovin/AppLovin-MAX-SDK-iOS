//
//  HSSNetGeneral.h
//  HSADXSDK
//
//  Created by admin on 2024/11/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSNetGeneral : NSObject

+(NSDictionary *)generalHeaders;

+(NSDictionary *)generalParams;

+(NSString *)requestId;

/// 配置埋点全局公共参数
+ (NSDictionary *)configTrackingGlobalCommonParams;
@end

NS_ASSUME_NONNULL_END
