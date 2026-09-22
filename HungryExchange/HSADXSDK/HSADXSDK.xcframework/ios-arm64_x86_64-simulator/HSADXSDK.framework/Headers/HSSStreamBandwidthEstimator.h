//
//  HSSStreamBandwidthEstimator.h
//  HSADXSDK
//
//  Created by 张松 on 2026/01/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSStreamBandwidthEstimator : NSObject

@property (nonatomic, assign, readonly) double speedShort;
@property (nonatomic, assign, readonly) double speedLong;

- (void)updateWithBytes:(long long)deltaBytes timestamp:(NSTimeInterval)ts;

+ (double)globalSpeedShort;
+ (double)globalSpeedLong;
+ (void)updateGlobalWithBytes:(long long)deltaBytes timestamp:(NSTimeInterval)ts;

@end

NS_ASSUME_NONNULL_END
