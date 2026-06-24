//
//  HSSdk.h
//  HSADXSDK
//
//  Created by admin on 2024/11/25.
//

#import <Foundation/Foundation.h>

@class HSSdkConfiguration;
@class HSSdkInitialConfiguration;
@class HSSdkSettings;
@class HSSdkConfigurationBuilder;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HSSdkInitialCompletionHander)(HSSdkConfiguration *configuration);
typedef void(^HSSdkHasInitialedCompletionHander)(HSSdkConfiguration *configuration, HSSdkConfigurationBuilder *builder);

@interface HSSdk : NSObject

/// SDK version
@property (nonatomic, copy, readonly) NSString *version;

/// 是否已经初始化
@property (nonatomic, assign, readonly, getter=isInitialized) BOOL initialized;
 ///SDK settings.
 
@property (nonatomic, strong, readonly) HSSdkSettings *settings;

+(instancetype)shared;

-(void)initializeWithConfiguration:(HSSdkInitialConfiguration *)configuration completionHandler:( HSSdkInitialCompletionHander)completionHandler;

- (void)initializedWithCompletionHandler:(HSSdkHasInitialedCompletionHander)completionHandler;

/**
 MaxBidding调用这个初始化方法
 @param configuration 初始化配置
 @param completionHandler 初始化完成回调
 */
- (void)initializeForBiddingWithConfiguration:(HSSdkInitialConfiguration *)configuration completionHandler:( HSSdkInitialCompletionHander)completionHandler;
/**
 设置 sdk 是否被禁用， 禁用之后内过功能失效
 @param shiled YES: 屏蔽  NO: 打开
 */
+(void)disableSdk:(BOOL)shiled;

/**
 设置播放器静音状态，优先级最高
 @param mute YES: 静音  NO:
 */
+(void)setMuteVideo:(BOOL)mute;


- (instancetype)init __attribute__((unavailable("Use +[HSSdk shared].")));
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
