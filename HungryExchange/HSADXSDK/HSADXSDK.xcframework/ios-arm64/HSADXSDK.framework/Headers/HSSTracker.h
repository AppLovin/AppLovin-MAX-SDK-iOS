//
//  HSSTracker.h
//  HSADXSDK
//
//  Created by admin on 2024/11/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSTracker : NSObject

+ (void)hss_tenPercentSamplingTracker:(NSString *)eventName params:(NSDictionary *)params;
/// 采样上报，本地采样
+ (void)hss_samplingTracker:(NSString *)eventName params:(NSDictionary *)params;

+(void)hss_tracker:(NSString *)eventName params:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
