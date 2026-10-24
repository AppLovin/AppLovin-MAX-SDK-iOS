//
//  HSSStreamMetrics.h
//  HSADXSDK
//
//  Created by 张松 on 2026/01/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HSSStreamBandwidthEstimator;

@interface HSSStreamMetrics : NSObject

- (instancetype)initWithBandwidthEstimator:(HSSStreamBandwidthEstimator *)bandwidthEstimator;

/// return progress [0..1], or -1 if expected <= 0
- (double)onReceived:(long long)received expected:(long long)expected;
- (double)speedShort;
- (double)speedLong;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
