//
//  HSSClickTrackingManager.h
//  HSADXSDK
//
//  Created by 张松 on 2025/11/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// InnerWebView 点击通知常量
FOUNDATION_EXPORT NSString *const HSSInnerWebClickNotification;
FOUNDATION_EXPORT NSString *const HSSInnerWebClickURLKey;
FOUNDATION_EXPORT NSString *const HSSInnerWebClickActionKey;
FOUNDATION_EXPORT NSString *const HSSInnerWebClickResultKey;
FOUNDATION_EXPORT NSString *const HSSInnerWebClickPointKey;
FOUNDATION_EXPORT NSString *const HSSInnerWebClickNumKey;

/**
 * 点击追踪管理器
 * 负责管理广告点击相关的计数器和状态
 */
@interface HSSClickTrackingManager : NSObject

#pragma mark - 只读属性

/// 计数器①：屏幕点击次数（adx_sdk_s_click）- 所有触摸都计数
@property (nonatomic, assign, readonly) NSInteger sClickNum;

/// 计数器②：有效点击次数（adx_sdk_click）- 只有点击有效元素才计数
@property (nonatomic, assign, readonly) NSInteger clickNum;

/// 计数器③：跳转结果次数（adx_sdk_click_result）- 只有执行跳转才计数
@property (nonatomic, assign, readonly) NSInteger resultClickNum;

/// 当前点击坐标（贯穿三个埋点）
@property (nonatomic, copy, readonly, nullable) NSString *currentClickPoint;

/// 当前素材索引（从 1 开始，每次素材切换 +1）
@property (nonatomic, assign, readonly) NSInteger currentSectionIndex;

/// 当前点击的元素（贯穿三个埋点）
@property (nonatomic, copy, readonly, nullable) NSString *currentElement;

/// 最近一次屏幕点击的时间戳（用于计算点击间隔）
@property (nonatomic, assign, readonly) NSTimeInterval lastScreenClickTimestamp;

#pragma mark - 初始化

/// 创建管理器实例
/// @param logPrefix 日志前缀，用于区分不同的 Ad 类（如 "InterstitialAd"）
/// @param paramsProvider 参数提供闭包（用于获取完整的广告参数，如 adsRelatedStat 方法返回的字典）
- (instancetype)initWithLogPrefix:(NSString *)logPrefix
                   paramsProvider:(nullable NSDictionary *(^)(void))paramsProvider;

#pragma mark - 状态管理方法

/// 重置所有追踪状态（新广告加载时调用，恢复初始值：s_click=0, click=0, result_click=0, section_index=1）
- (void)resetClickCounters;

/// 递增素材索引（素材切换时调用，section_index++）
- (void)incrementSectionIndex;

/// 更新当前点击的元素
/// @param element 元素名称（如 "video", "ctaButton", "pic" 等）
- (void)updateCurrentElement:(nullable NSString *)element;

#pragma mark - 埋点上报方法

/// 上报 adx_sdk_s_click 埋点（屏幕点击）
/// @param clickPoint 点击坐标
/// @param adRelatedParams 广告相关参数（由外部传入，如 adsRelatedStat 方法返回的字典）
- (void)sendScreenClickTracking:(CGPoint)clickPoint 
                adRelatedParams:(nullable NSDictionary *)adRelatedParams;

/// 上报 adx_sdk_click 埋点（有效点击）
/// @param extraParams 额外参数（可选，如 is_full_screen_click 等）
/// @param adRelatedParams 广告相关参数（由外部传入）
- (void)sendValidClickTracking:(nullable NSDictionary *)extraParams 
               adRelatedParams:(nullable NSDictionary *)adRelatedParams;

/// 上报 adx_sdk_click_result 埋点（跳转结果）
/// @param result 跳转是否成功
/// @param linkUrl 跳转链接
/// @param context 跳转上下文（包含跳转相关的特定参数）
/// @param adRelatedParams 广告相关参数（由外部传入）
- (void)sendClickResultTracking:(BOOL)result 
                        linkUrl:(nullable NSString *)linkUrl 
                        context:(nullable id)context
                         isAuto:(BOOL)isAuto
                adRelatedParams:(nullable NSDictionary *)adRelatedParams;

@end

NS_ASSUME_NONNULL_END

