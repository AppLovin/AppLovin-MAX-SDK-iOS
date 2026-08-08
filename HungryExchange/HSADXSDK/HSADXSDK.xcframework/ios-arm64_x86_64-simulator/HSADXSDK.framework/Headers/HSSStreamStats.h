//
//  HSSStreamStats.h
//  HSADXSDK
//
//  Created by 张松 on 2026/01/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSStreamStats : NSObject

@property (nonatomic, assign, readonly) double sizeMB;
@property (nonatomic, assign, readonly) double downloadSizeMB;
@property (nonatomic, assign, readonly) double speedKbps;
@property (nonatomic, assign, readonly) NSTimeInterval downloadTimeSec;
@property (nonatomic, assign, readonly) NSTimeInterval totalTimeSec;
@property (nonatomic, copy, readonly, nullable) NSString *resourceHost;
@property (nonatomic, copy, readonly, nullable) NSString *resourceURL;

@property (nonatomic, assign, readonly) BOOL isReused;///是否复用active
@property (nonatomic, copy, readonly, nullable) NSString *reuseState;/// 复用active的state
@property (nonatomic, assign, readonly) BOOL isReseme;///是否是断点续传
@property (nonatomic, assign, readonly) double resumeOffset;/// 断点续传开始起点
@property (nonatomic, assign, readonly) BOOL isHitCache;///是否是断点续传


- (instancetype)initWithSizeMB:(double)sizeMB
                 downloadSizeMB:(double)downloadSizeMB
                      speedKbps:(double)speedKbps
               downloadTimeSec:(NSTimeInterval)downloadTimeSec
                  totalTimeSec:(NSTimeInterval)totalTimeSec
                  resourceHost:(nullable NSString *)resourceHost
                   resourceURL:(nullable NSString *)resourceURL
                      isReused:(BOOL)isReused
                    reuseState:(nullable NSString *)reuseState
                      isReseme:(BOOL)isResume
                  resumeOffset:(double)resumeOffset
                    isHitCache:(BOOL)isHitCache;

@end

NS_ASSUME_NONNULL_END
