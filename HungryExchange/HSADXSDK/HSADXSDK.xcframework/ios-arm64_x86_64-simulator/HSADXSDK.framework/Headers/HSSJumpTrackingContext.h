//
//  HSSJumpTrackingContext.h
//  HSADXSDK
//
//  Created on 2025-11-14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 跳转结果追踪通知
extern NSNotificationName const HSSJumpResultTrackingNotification;

/// Deeplink 跳转完成通知（每次 deepLink 跳转完成后发送，用于 adx_sdk_dp 埋点上报）
extern NSNotificationName const HSSDeeplinkJumpCompletedNotification;

/**
 * 跳转追踪上下文
 * 用于记录广告点击跳转过程中的所有关键信息，供 adx_sdk_click_result 埋点使用
 */
@interface HSSJumpTrackingContext : NSObject
#pragma mark - 第一次尝试（first_source / first_action）

/// 第一次尝试的URL来源：skan/dp/landurl/vasturl
@property (nonatomic, copy, nullable) NSString *firstSource;

/// 第一次尝试的操作类型：dp/in_store/out_store/inner_web/outer_web
@property (nonatomic, copy, nullable) NSString *firstAction;

#pragma mark - 成功跳转（succ_source / succ_action）

/// 当前执行的URL来源：skan/dp/landurl/vasturl
@property (nonatomic, copy, nullable) NSString *currentSource;

/// 当前的操作类型：dp/in_store/out_store/inner_web/outer_web
@property (nonatomic, copy, nullable) NSString *currentAction;

#pragma mark - SKAdNetwork

/// 是否包含 SKAdNetwork 参数：0-无，1-有
@property (nonatomic, assign) BOOL hasSKAN;

#pragma mark - 跳转结果

/// 跳转结果：success/fail
@property (nonatomic, assign) BOOL result;

/// 失败后是否应该重试下一个 URL（根据当前 URL 类型决定）
@property (nonatomic, assign) BOOL shouldRetryOnFailure;

/// dp的跳转结果，只有在firstAction为dp时赋值
@property (nonatomic, assign) BOOL dpResult;
/// 尝试deepLink时的url
@property (nonatomic, copy) NSString *dpActionUrl;


@property (nonatomic, copy, nullable) NSString *webViewUrl;

/// Deeplink URL地址
@property (nonatomic, copy, nullable) NSString *deeplink;

/// Landing URL地址
@property (nonatomic, copy, nullable) NSString *landingUrl;

/// VAST URL地址
@property (nonatomic, copy, nullable) NSString *vastUrl;

/// VAST类型：click/comp
@property (nonatomic, copy, nullable) NSString *vastType;

@property (nonatomic, copy, nullable) NSString *openApp;

/// 跳转的error信息，只有result = NO时有用
@property (nonatomic, strong, nullable) NSError *error;

@property (nonatomic, assign) BOOL autoPresentAppStore;

#pragma mark - 广告实例标识（用于精确匹配，避免多实例重复上报）

/// 素材 ID（用于区分同一广告位的不同素材）
@property (nonatomic, copy, nullable) NSString *crid;

- (NSDictionary *)configParams;

@end

NS_ASSUME_NONNULL_END

