//
//  HSSStreamHeadChecker.h
//  HSADXSDK
//
//  Created by 张松 on 2026/01/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HSSStreamCacheManager;

@interface HSSStreamHeadCheckResult : NSObject

@property (nonatomic, assign) BOOL cacheHit;
@property (nonatomic, assign) BOOL shouldTruncate;
@property (nonatomic, assign) long long totalLength;
@property (nonatomic, copy) NSString *mimeType;

@end

@interface HSSStreamHeadChecker : NSObject

@property (nonatomic, assign, readonly) BOOL isChecking;
@property (nonatomic, assign, readonly) BOOL didCheck;
@property (nonatomic, strong, readonly, nullable) HSSStreamHeadCheckResult *lastResult;

- (instancetype)initWithURL:(NSURL *)url cacheManager:(HSSStreamCacheManager *)cacheManager;

- (void)checkIfNeededWithCompletion:(void(^)(HSSStreamHeadCheckResult *result))completion;

@end

NS_ASSUME_NONNULL_END
