//
//  HSSStreamDecisionEngine.h
//  HSADXSDK
//
//  Created by 张松 on 2026/01/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSStreamDecisionEngine : NSObject

@property (nonatomic, assign, readonly) BOOL shouldReady;
@property (nonatomic, assign, readonly) long long lastExpected;
@property (nonatomic, assign, readonly) long long lastReceived;
@property (nonatomic, assign, readonly) BOOL lastMoovReady;
@property (nonatomic, assign, readonly) double lastSpeedStable;
@property (nonatomic, assign, readonly) double lastTargetRatio;
@property (nonatomic, assign, readonly) BOOL lastShouldReady;
@property (nonatomic, assign, readonly) BOOL lastCanReachTargetIn10;

- (instancetype)initWithStartTs:(NSTimeInterval)startTs timeout:(NSTimeInterval)timeout;

- (void)onMoovFound:(BOOL)found;
- (void)onTimeoutCheckWithExpected:(long long)expected
                          received:(long long)received
                        speedShort:(double)speedShort
                         speedLong:(double)speedLong
                         moovReady:(BOOL)moovReady;
- (void)onDownloadCompletedWithExpected:(long long)expected received:(long long)received;

@end

NS_ASSUME_NONNULL_END
